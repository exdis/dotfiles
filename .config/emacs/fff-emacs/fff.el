;;; fff.el --- Fast file finder for Emacs powered by fff-c -*- lexical-binding: t; -*-

;; Copyright (C) 2024
;; Author: Emacs fff integration
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: files, matching, tools

;;; Commentary:
;; This package integrates the fff (fast file finder) Rust engine with Emacs.
;; It provides blazing fast fuzzy file search and live grep powered by
;; fff-c's file indexing, Smith-Waterman matching, and frecency scoring.
;;
;; Main entry points:
;;   `fff-find-file'  — fuzzy file search (replacement for project-find-file)
;;   `fff-live-grep'  — content search (replacement for consult-ripgrep)
;;
;; Works with vertico, orderless, and marginalia out of the box.

;;; Code:

(require 'fff-module)
(require 'project)

;; ── Customization ──────────────────────────────────────────────

(defgroup fff nil
  "Fast file finder powered by fff-c."
  :group 'files
  :prefix "fff-")

(defcustom fff-page-size 200
  "Number of results to fetch per search query."
  :type 'integer
  :group 'fff)

(defcustom fff-grep-page-limit 50
  "Number of results to fetch per grep query."
  :type 'integer
  :group 'fff)

(defcustom fff-grep-time-budget-ms 500
  "Time budget in milliseconds for grep queries.
Prevents blocking Emacs on large codebases."
  :type 'integer
  :group 'fff)

(defcustom fff-db-directory
  (expand-file-name "fff" user-emacs-directory)
  "Directory for fff databases (frecency, history)."
  :type 'directory
  :group 'fff)

;; ── Instance management ────────────────────────────────────────

(defvar fff--instances (make-hash-table :test 'equal)
  "Hash table mapping project root -> fff handle.")

(defvar fff--last-query nil
  "Last search query, used for frecency tracking.")

(defun fff--db-path (project-root name)
  "Return the database path for NAME in PROJECT-ROOT."
  (let* ((safe-name (replace-regexp-in-string "/" "_" project-root))
         (dir (expand-file-name safe-name fff-db-directory)))
    (make-directory dir t)
    (expand-file-name name dir)))

(defun fff--get-instance (&optional project-root)
  "Get or create an fff instance for PROJECT-ROOT."
  (let* ((root (or project-root
                   (when-let* ((proj (project-current)))
                     (project-root proj))
                   default-directory))
         (root (expand-file-name root)))
    (or (gethash root fff--instances)
        (let* ((frecency-db (fff--db-path root "frecency.mdb"))
               (history-db (fff--db-path root "history.mdb"))
               (handle (fff-module--create-instance root frecency-db history-db)))
          (puthash root handle fff--instances)
          handle))))

(defun fff-destroy-instance (&optional project-root)
  "Destroy the fff instance for PROJECT-ROOT."
  (interactive)
  (let* ((root (or project-root
                   (when-let* ((proj (project-current)))
                     (project-root proj))
                   default-directory))
         (root (expand-file-name root))
         (handle (gethash root fff--instances)))
    (when handle
      (fff-module--destroy handle)
      (remhash root fff--instances))))

(defun fff-destroy-all-instances ()
  "Destroy all fff instances."
  (interactive)
  (maphash (lambda (_root handle)
             (fff-module--destroy handle))
           fff--instances)
  (clrhash fff--instances))

;; ── File search ────────────────────────────────────────────────

(defun fff--search (query)
  "Search for QUERY and return list of relative paths."
  (let* ((handle (fff--get-instance))
         (current-file (when buffer-file-name
                         (file-relative-name buffer-file-name
                                             (when-let* ((proj (project-current)))
                                               (project-root proj)))))
         (result (fff-module--search handle query current-file fff-page-size)))
    ;; result is (ITEMS TOTAL-MATCHED TOTAL-FILES)
    ;; ITEMS is list of (relative-path . score)
    (car result)))

(defun fff--search-candidates (query)
  "Return candidate strings for QUERY."
  (mapcar #'car (fff--search query)))

(defvar fff--find-file-history nil
  "History for `fff-find-file'.")

;;;###autoload
(defun fff-find-file ()
  "Find a file using fff fuzzy search.
Uses the fff engine for blazing fast fuzzy matching with
frecency-boosted results.  Works with vertico."
  (interactive)
  (let* ((project (project-current))
         (root (if project (project-root project) default-directory))
         (handle (fff--get-instance root))
         ;; Dynamically generate candidates based on minibuffer input
         (selected
          (minibuffer-with-setup-hook
              (lambda ()
                ;; Wait for scan to complete if needed
                (when (fff-module--is-scanning handle)
                  (message "fff: waiting for file index...")))
            (completing-read
             (format "fff [%s]: "
                     (file-name-nondirectory (directory-file-name root)))
             (completion-table-dynamic
              (lambda (input)
                (if (string-empty-p input)
                    ;; Return empty query results (frecency-ordered)
                    (fff--search-candidates "")
                  (fff--search-candidates input))))
             nil nil nil 'fff--find-file-history))))
    (when selected
      (setq fff--last-query nil)
      ;; Track the open for frecency
      (fff-module--track-open handle (expand-file-name selected root)
                              (or fff--last-query ""))
      (find-file (expand-file-name selected root)))))

;; ── Live grep ──────────────────────────────────────────────────

(defun fff--grep (query &optional mode)
  "Grep for QUERY with MODE (0=plain 1=regex 2=fuzzy).
Returns list of (relative-path line-number col content)."
  (let* ((handle (fff--get-instance))
         (result (fff-module--live-grep handle query (or mode 0)
                                        fff-grep-page-limit
                                        fff-grep-time-budget-ms)))
    ;; result is (ITEMS TOTAL-MATCHED TOTAL-FILES NEXT-OFFSET)
    (car result)))

(defvar fff--grep-history nil
  "History for `fff-live-grep'.")

;;;###autoload
(defun fff-live-grep ()
  "Live grep using fff engine.
Uses fff's SIMD-accelerated content search across indexed files."
  (interactive)
  (let* ((project (project-current))
         (root (if project (project-root project) default-directory))
         (handle (fff--get-instance root))
         (candidates
          (completion-table-dynamic
           (lambda (input)
             (if (or (string-empty-p input) (< (length input) 3))
                 nil
               (let ((matches (fff--grep input)))
                 (mapcar
                  (lambda (m)
                    (let ((path (nth 0 m))
                          (line (nth 1 m))
                          (content (string-trim (or (nth 3 m) ""))))
                      (propertize
                       (format "%s:%d: %s" path line content)
                       'fff-path path
                       'fff-line line
                       'fff-col (nth 2 m))))
                  matches))))))
         (selected
          (completing-read
           (format "fff grep [%s]: "
                   (file-name-nondirectory (directory-file-name root)))
           candidates
           nil nil nil 'fff--grep-history)))
    (when (and selected (not (string-empty-p selected)))
      (let ((path (get-text-property 0 'fff-path selected))
            (line (get-text-property 0 'fff-line selected))
            (col  (get-text-property 0 'fff-col selected)))
        (if path
            (progn
              (find-file (expand-file-name path root))
              (goto-char (point-min))
              (forward-line (1- line))
              (when (and col (> col 0))
                (forward-char (1- col))))
          ;; Fallback: parse the format "path:line: content"
          (when (string-match "\\`\\(.+\\):\\([0-9]+\\):" selected)
            (let ((fpath (match-string 1 selected))
                  (fline (string-to-number (match-string 2 selected))))
              (find-file (expand-file-name fpath root))
              (goto-char (point-min))
              (forward-line (1- fline)))))))))

;; ── Frecency tracking ──────────────────────────────────────────

(defun fff--track-file-open ()
  "Track the current file open for frecency scoring."
  (when-let* ((file buffer-file-name)
              (proj (project-current))
              (root (project-root proj))
              (handle (gethash (expand-file-name root) fff--instances)))
    (condition-case nil
        (fff-module--track-open handle file (or fff--last-query ""))
      (error nil))))

;; Add to find-file-hook for automatic frecency tracking
(add-hook 'find-file-hook #'fff--track-file-open)

;; ── Scan management ────────────────────────────────────────────

;;;###autoload
(defun fff-rescan ()
  "Trigger a rescan of the file index for the current project."
  (interactive)
  (let ((handle (fff--get-instance)))
    (fff-module--scan-files handle)
    (message "fff: rescanning files...")))

;;;###autoload
(defun fff-refresh-git ()
  "Refresh git status cache for the current project."
  (interactive)
  (let ((handle (fff--get-instance)))
    (let ((count (fff-module--refresh-git handle)))
      (message "fff: refreshed git status (%d files updated)" count))))

(provide 'fff)
;;; fff.el ends here

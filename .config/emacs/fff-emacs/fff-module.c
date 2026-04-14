/*
 * fff-module.c — Emacs dynamic module wrapping the fff-c library.
 *
 * Provides:
 *   fff-module--create-instance (base-path frecency-db-path history-db-path)
 *   fff-module--destroy (handle)
 *   fff-module--search (handle query current-file page-size)
 *   fff-module--live-grep (handle query mode smart-case page-limit)
 *   fff-module--track-open (handle file-path query)
 *   fff-module--scan-files (handle)
 *   fff-module--is-scanning (handle)
 *   fff-module--refresh-git (handle)
 */

#include <emacs-module.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "fff.h"

int plugin_is_GPL_compatible;

/* ── helpers ─────────────────────────────────────────────────── */

/* Extract a C string from an Emacs string value. Caller must free(). */
static char *
extract_string(emacs_env *env, emacs_value val)
{
  ptrdiff_t len = 0;
  env->copy_string_contents(env, val, NULL, &len);
  if (env->non_local_exit_check(env) != emacs_funcall_exit_return)
    return NULL;
  char *buf = malloc(len);
  if (!buf) return NULL;
  env->copy_string_contents(env, val, buf, &len);
  return buf;
}

/* Extract a C string, or NULL if the value is nil. Caller must free(). */
static char *
extract_string_or_null(emacs_env *env, emacs_value val)
{
  emacs_value Qnil = env->intern(env, "nil");
  if (env->eq(env, val, Qnil))
    return NULL;
  return extract_string(env, val);
}

/* Signal an error with a message string. */
static void
signal_error(emacs_env *env, const char *msg)
{
  emacs_value Qerror = env->intern(env, "error");
  emacs_value data = env->make_string(env, msg, strlen(msg));
  env->non_local_exit_signal(env, Qerror, data);
}

/* Make an Emacs string from a C string, or nil if NULL. */
static emacs_value
make_string_or_nil(emacs_env *env, const char *s)
{
  if (!s)
    return env->intern(env, "nil");
  return env->make_string(env, s, strlen(s));
}

/* ── fff handle stored as user-ptr ──────────────────────────── */

static void
fff_handle_finalizer(void *ptr)
{
  if (ptr)
    fff_destroy(ptr);
}

/* ── fff-module--create-instance ─────────────────────────────── */

static emacs_value
Ffff_create_instance(emacs_env *env, ptrdiff_t nargs,
                     emacs_value *args, void *data)
{
  (void)data;
  char *base_path = extract_string(env, args[0]);
  if (!base_path) return env->intern(env, "nil");

  char *frecency_db = (nargs > 1) ? extract_string_or_null(env, args[1]) : NULL;
  char *history_db  = (nargs > 2) ? extract_string_or_null(env, args[2]) : NULL;

  struct FffResult *r = fff_create_instance(
    base_path, frecency_db, history_db,
    false,   /* use_unsafe_no_lock */
    true,    /* warmup_mmap_cache */
    false    /* ai_mode */
  );

  free(base_path);
  free(frecency_db);
  free(history_db);

  if (!r) {
    signal_error(env, "fff_create_instance returned NULL");
    return env->intern(env, "nil");
  }

  if (!r->success) {
    const char *err = r->error ? r->error : "unknown error";
    signal_error(env, err);
    fff_free_result(r);
    return env->intern(env, "nil");
  }

  void *handle = r->handle;
  fff_free_result(r);

  return env->make_user_ptr(env, fff_handle_finalizer, handle);
}

/* ── fff-module--destroy ─────────────────────────────────────── */

static emacs_value
Ffff_destroy(emacs_env *env, ptrdiff_t nargs,
             emacs_value *args, void *data)
{
  (void)data; (void)nargs;
  void *handle = env->get_user_ptr(env, args[0]);
  if (handle) {
    fff_destroy(handle);
    env->set_user_ptr(env, args[0], NULL);
    env->set_user_finalizer(env, args[0], NULL);
  }
  return env->intern(env, "nil");
}

/* ── fff-module--search ──────────────────────────────────────── */

static emacs_value
Ffff_search(emacs_env *env, ptrdiff_t nargs,
            emacs_value *args, void *data)
{
  (void)data;
  void *handle = env->get_user_ptr(env, args[0]);
  if (!handle) {
    signal_error(env, "fff handle is NULL");
    return env->intern(env, "nil");
  }

  char *query = extract_string(env, args[1]);
  if (!query) return env->intern(env, "nil");

  char *current_file = (nargs > 2) ? extract_string_or_null(env, args[2]) : NULL;
  int64_t page_size  = (nargs > 3) ? env->extract_integer(env, args[3]) : 100;

  struct FffResult *r = fff_search(
    handle, query, current_file,
    0,           /* max_threads = auto */
    0,           /* page_index */
    (uint32_t)page_size,
    0,           /* combo_boost_multiplier = default */
    0            /* min_combo_count = default */
  );

  free(query);
  free(current_file);

  if (!r) {
    signal_error(env, "fff_search returned NULL");
    return env->intern(env, "nil");
  }

  if (!r->success) {
    const char *err = r->error ? r->error : "search error";
    signal_error(env, err);
    fff_free_result(r);
    return env->intern(env, "nil");
  }

  struct FffSearchResult *sr = (struct FffSearchResult *)r->handle;
  fff_free_result(r);

  if (!sr) return env->intern(env, "nil");

  /* Build a list of (relative-path . score) cons cells */
  emacs_value Qcons = env->intern(env, "cons");
  emacs_value Qnil  = env->intern(env, "nil");
  emacs_value list  = Qnil;

  /* Build in reverse, then it's already in score order
     since we prepend from last to first */
  for (int32_t i = (int32_t)sr->count - 1; i >= 0; i--) {
    const struct FffFileItem *item = fff_search_result_get_item(sr, (uint32_t)i);
    const struct FffScore *score = fff_search_result_get_score(sr, (uint32_t)i);
    if (!item) continue;

    emacs_value path_val = make_string_or_nil(env, item->relative_path);
    emacs_value score_val = env->make_integer(env, score ? score->total : 0);
    emacs_value cell_args[2] = { path_val, score_val };
    emacs_value cell = env->funcall(env, Qcons, 2, cell_args);

    emacs_value list_args[2] = { cell, list };
    list = env->funcall(env, Qcons, 2, list_args);
  }

  /* Also return metadata: total_matched and total_files */
  emacs_value total_matched = env->make_integer(env, sr->total_matched);
  emacs_value total_files = env->make_integer(env, sr->total_files);

  fff_free_search_result(sr);

  /* Return (list results total-matched total-files) */
  emacs_value Qlist = env->intern(env, "list");
  emacs_value result_args[3] = { list, total_matched, total_files };
  return env->funcall(env, Qlist, 3, result_args);
}

/* ── fff-module--live-grep ───────────────────────────────────── */

static emacs_value
Ffff_live_grep(emacs_env *env, ptrdiff_t nargs,
               emacs_value *args, void *data)
{
  (void)data;
  void *handle = env->get_user_ptr(env, args[0]);
  if (!handle) {
    signal_error(env, "fff handle is NULL");
    return env->intern(env, "nil");
  }

  char *query = extract_string(env, args[1]);
  if (!query) return env->intern(env, "nil");

  /* mode: 0=plain, 1=regex, 2=fuzzy */
  int64_t mode        = (nargs > 2) ? env->extract_integer(env, args[2]) : 0;
  bool smart_case     = true;
  int64_t page_limit  = (nargs > 3) ? env->extract_integer(env, args[3]) : 50;
  int64_t time_budget = (nargs > 4) ? env->extract_integer(env, args[4]) : 500;

  struct FffResult *r = fff_live_grep(
    handle, query,
    (uint8_t)mode,
    0,              /* max_file_size = default 10MB */
    5,              /* max_matches_per_file */
    smart_case,
    0,              /* file_offset */
    (uint32_t)page_limit,
    (uint64_t)time_budget, /* time_budget_ms */
    0,              /* before_context */
    0,              /* after_context */
    false           /* classify_definitions */
  );

  free(query);

  if (!r) {
    signal_error(env, "fff_live_grep returned NULL");
    return env->intern(env, "nil");
  }

  if (!r->success) {
    const char *err = r->error ? r->error : "grep error";
    signal_error(env, err);
    fff_free_result(r);
    return env->intern(env, "nil");
  }

  struct FffGrepResult *gr = (struct FffGrepResult *)r->handle;
  fff_free_result(r);

  if (!gr) return env->intern(env, "nil");

  /* Build list of (relative-path line-number col line-content) */
  emacs_value Qlist = env->intern(env, "list");
  emacs_value Qcons = env->intern(env, "cons");
  emacs_value Qnil  = env->intern(env, "nil");
  emacs_value list  = Qnil;

  for (int32_t i = (int32_t)gr->count - 1; i >= 0; i--) {
    const struct FffGrepMatch *m = fff_grep_result_get_match(gr, (uint32_t)i);
    if (!m) continue;

    emacs_value path_val    = make_string_or_nil(env, m->relative_path);
    emacs_value line_val    = env->make_integer(env, (int64_t)m->line_number);
    emacs_value col_val     = env->make_integer(env, (int64_t)m->col);
    emacs_value content_val = make_string_or_nil(env, m->line_content);

    emacs_value item_args[4] = { path_val, line_val, col_val, content_val };
    emacs_value item = env->funcall(env, Qlist, 4, item_args);

    emacs_value list_args[2] = { item, list };
    list = env->funcall(env, Qcons, 2, list_args);
  }

  emacs_value total_matched = env->make_integer(env, gr->total_matched);
  emacs_value total_files = env->make_integer(env, gr->total_files);
  emacs_value next_offset = env->make_integer(env, gr->next_file_offset);

  fff_free_grep_result(gr);

  emacs_value result_args[4] = { list, total_matched, total_files, next_offset };
  return env->funcall(env, Qlist, 4, result_args);
}

/* ── fff-module--track-open ──────────────────────────────────── */

static emacs_value
Ffff_track_open(emacs_env *env, ptrdiff_t nargs,
                emacs_value *args, void *data)
{
  (void)data;
  void *handle = env->get_user_ptr(env, args[0]);
  if (!handle) return env->intern(env, "nil");

  char *file_path = extract_string(env, args[1]);
  if (!file_path) return env->intern(env, "nil");

  char *query = (nargs > 2) ? extract_string_or_null(env, args[2]) : NULL;

  struct FffResult *r = fff_track_query(handle, query ? query : "", file_path);
  free(file_path);
  free(query);

  if (r) fff_free_result(r);
  return env->intern(env, "t");
}

/* ── fff-module--scan-files ──────────────────────────────────── */

static emacs_value
Ffff_scan_files(emacs_env *env, ptrdiff_t nargs,
                emacs_value *args, void *data)
{
  (void)data; (void)nargs;
  void *handle = env->get_user_ptr(env, args[0]);
  if (!handle) return env->intern(env, "nil");

  struct FffResult *r = fff_scan_files(handle);
  if (r) {
    bool ok = r->success;
    fff_free_result(r);
    return env->intern(env, ok ? "t" : "nil");
  }
  return env->intern(env, "nil");
}

/* ── fff-module--is-scanning ─────────────────────────────────── */

static emacs_value
Ffff_is_scanning(emacs_env *env, ptrdiff_t nargs,
                 emacs_value *args, void *data)
{
  (void)data; (void)nargs;
  void *handle = env->get_user_ptr(env, args[0]);
  if (!handle) return env->intern(env, "nil");

  bool scanning = fff_is_scanning(handle);
  return env->intern(env, scanning ? "t" : "nil");
}

/* ── fff-module--refresh-git ─────────────────────────────────── */

static emacs_value
Ffff_refresh_git(emacs_env *env, ptrdiff_t nargs,
                 emacs_value *args, void *data)
{
  (void)data; (void)nargs;
  void *handle = env->get_user_ptr(env, args[0]);
  if (!handle) return env->intern(env, "nil");

  struct FffResult *r = fff_refresh_git_status(handle);
  if (!r) return env->intern(env, "nil");

  int64_t updated = r->int_value;
  fff_free_result(r);
  return env->make_integer(env, updated);
}

/* ── module init ─────────────────────────────────────────────── */

static void
def(emacs_env *env, const char *name,
    ptrdiff_t min_arity, ptrdiff_t max_arity,
    emacs_value (*func)(emacs_env *, ptrdiff_t, emacs_value *, void *),
    const char *doc)
{
  emacs_value fn = env->make_function(env, min_arity, max_arity, func, doc, NULL);
  emacs_value Qfset = env->intern(env, "fset");
  emacs_value Qsym  = env->intern(env, name);
  emacs_value fset_args[2] = { Qsym, fn };
  env->funcall(env, Qfset, 2, fset_args);
}

int
emacs_module_init(struct emacs_runtime *runtime)
{
  if (runtime->size < sizeof(*runtime))
    return 1;

  emacs_env *env = runtime->get_environment(runtime);
  if (env->size < sizeof(*env))
    return 2;

  def(env, "fff-module--create-instance", 1, 3, Ffff_create_instance,
      "Create an fff instance for BASE-PATH.\n"
      "Optional FRECENCY-DB-PATH and HISTORY-DB-PATH for persistence.");

  def(env, "fff-module--destroy", 1, 1, Ffff_destroy,
      "Destroy an fff instance HANDLE.");

  def(env, "fff-module--search", 2, 4, Ffff_search,
      "Search for QUERY in fff instance HANDLE.\n"
      "Optional CURRENT-FILE and PAGE-SIZE.\n"
      "Returns (RESULTS TOTAL-MATCHED TOTAL-FILES).");

  def(env, "fff-module--live-grep", 2, 5, Ffff_live_grep,
      "Grep for QUERY in fff instance HANDLE.\n"
      "Optional MODE (0=plain 1=regex 2=fuzzy), PAGE-LIMIT, TIME-BUDGET-MS.\n"
      "Returns (RESULTS TOTAL-MATCHED TOTAL-FILES NEXT-OFFSET).");

  def(env, "fff-module--track-open", 2, 3, Ffff_track_open,
      "Track file open for frecency. HANDLE, FILE-PATH, optional QUERY.");

  def(env, "fff-module--scan-files", 1, 1, Ffff_scan_files,
      "Trigger a rescan of the file index for HANDLE.");

  def(env, "fff-module--is-scanning", 1, 1, Ffff_is_scanning,
      "Return t if HANDLE is currently scanning, nil otherwise.");

  def(env, "fff-module--refresh-git", 1, 1, Ffff_refresh_git,
      "Refresh git status cache for HANDLE. Returns count of updated files.");

  /* Provide the feature */
  emacs_value Qprovide = env->intern(env, "provide");
  emacs_value Qfeat    = env->intern(env, "fff-module");
  emacs_value provide_args[1] = { Qfeat };
  env->funcall(env, Qprovide, 1, provide_args);

  return 0;
}

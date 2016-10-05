#!/usr/bin/python2.7

import i3

workspaces = i3.get_workspaces()
outputs = i3.get_outputs()
leftWorkspaces = ["1", "10"]
rightWorkspaces = map(lambda x: str(x), range(2, 6))
for workspace in workspaces:
    name = workspace["name"]
    if name in leftWorkspaces:
        i3.workspace(workspace["name"])
        i3.command("move", "workspace to output eDP1")
    elif name in rightWorkspaces:
        i3.workspace(workspace["name"])
        i3.command("move", "workspace to output DP1-1")

i3.workspace("1")

def _js_tool_impl(ctx):
    """
    Implements a js tool executable
    """
    js_content = """
require("{package}")
""".format(package=ctx.attr.package)
    js = ctx.actions.declare_file("index.js")
    ctx.actions.write(
        output = js,
        content = js_content,
    )

    package_content = """
{{
  "name": "{js_path}",
  "main": "{package}",
  "dependencies": {{
    "{package}": "*"
  }}
}}
""".format(
        package=ctx.attr.package,
        js_path = js.path,
    )
    package_json = ctx.actions.declare_file("package.json")
    ctx.actions.write(
        output = package_json,
        content = package_content,
    )

    script_content = """#!/bin/bash
export NODE_PATH=./external
{node_bin} index.js $@
""".format(
        node_bin="./external/node/node",
        js_path=js.path,
    )
    executable = ctx.actions.declare_file(ctx.attr.name + ".sh")
    ctx.actions.write(
        output = executable,
        content = script_content,
    )

    data = [ctx.attr.tool_dep, ctx.attr.node_dep] + ctx.attr.data

    data_files = depset(transitive = [d[DefaultInfo].files for d in data])
    runfiles = ctx.runfiles(transitive_files = data_files)
    runfiles = runfiles.merge(ctx.runfiles([package_json, js]))
    return [
        DefaultInfo(
            runfiles = runfiles,
            executable = executable,
        ),
    ]

js_tool = rule(
    implementation = _js_tool_impl,
    executable = True,
    attrs = {
        "data": attr.label_list(
            allow_files = True,
        ),
        "node_dep": attr.label(
            allow_files = False,
        ),
        "tool_dep": attr.label(
            allow_files = False,
        ),
        "package": attr.string(),
    },
)

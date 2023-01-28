def _local_archive_impl(ctx):
    """Implementation of local_archive rule."""

    # Extract archive to the root of the repository.
    path = ctx.path(ctx.attr.archive)
    download_info = ctx.extract(path, "", ctx.attr.strip_prefix)

    # Set up WORKSPACE to create @{name}// repository:
    ctx.file("WORKSPACE", 'workspace(name = "{}")\n'.format(ctx.name))

    # Link optional BUILD file:
    if ctx.attr.build_file:
        ctx.delete("BUILD.bazel")
        ctx.symlink(ctx.attr.build_file, "BUILD.bazel")

local_archive = repository_rule(
    implementation = _local_archive_impl,
    attrs = {
        "archive": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "Label for the archive that contains the target.",
        ),
        "strip_prefix": attr.string(doc = "Optional path prefix to strip from the extracted files."),
        "build_file": attr.label(
            allow_single_file = True,
            doc = "Optional label for a BUILD file to be used when setting the repository.",
        ),
    },
)

using Pkg: Pkg
cd(@__DIR__)
Pkg.activate(pwd())
using Remark: Remark

function build()
    dir = Remark.slideshow(
        "content_src/pres.md", "out";
        css="content_src/style.css",
        title="ChainRules"
    )
    cp("content_src/assets", joinpath(dir, "build", "assets"); force=true)
end

slideshow_dir = build()

#Remark.open(slideshow_dir)

#exit()

###

using FileWatching
path = "src/pres.md"
while true
    build()
    @info "Rebuilt"
    FileWatching.watch_folder("content_src/")
end


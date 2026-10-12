swift test $([ "$(uname)" = "Darwin" ] && echo "-Xswiftc -Xfrontend -Xswiftc -enable-cross-import-overlays -Xswiftc -target -Xswiftc arm64-apple-macosx15.0")


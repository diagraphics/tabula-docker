#! /bin/sh

jarfile="$1"
modules="$(jdeps --ignore-missing-deps --print-module-deps "$jarfile")"

jlink --module-path $JAVA_HOME/jmods \
    --add-modules "$modules" \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=1 \
    --output target/runtime

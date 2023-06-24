#!/bin/bash

BUILDDIR="public"
DISTDIR="../../dist"

cp "$BUILDDIR"/index.html "$DISTDIR"/index.html
cp -r "$BUILDDIR"/posts "$DISTDIR"
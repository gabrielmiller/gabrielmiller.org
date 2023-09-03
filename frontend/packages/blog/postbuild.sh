#!/bin/bash

BUILDDIR="public"
DISTDIR="../../dist"

cp "$BUILDDIR"/index.html "$DISTDIR"/index.html
cp "$BUILDDIR"/archive.html "$DISTDIR"/archive.html
cp -r "$BUILDDIR"/static "$DISTDIR" #images
cp -r "$BUILDDIR"/posts "$DISTDIR"
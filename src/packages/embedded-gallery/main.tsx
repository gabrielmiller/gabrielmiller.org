import { h, render } from 'preact';
import EmbeddedGallery from './EmbeddedGallery';

document.addEventListener("click", function (event) {
  const target = event.target;
  if (target === undefined || target === null) {
    return;
  }

  let openerElement;
  let srcElement;

  if (target.tagName === "BUTTON") {
    openerElement = target;
    srcElement = target.children[0];
  } else {
    openerElement = target.parentElement;
    srcElement = target;
  }

  let isGalleryOpener = false;
  for (const c of openerElement.classList) {
    if (c === "gallery-opener") {
      isGalleryOpener = true;
      break;
    }
  }

  if (!isGalleryOpener) {
    return;
  }

  const contextElement = document.getElementById("embedded-gallery-context");
  if (contextElement == null) {
    throw new Error("No context element found");
  }

  const src = srcElement.getAttribute("src");
  MountOrUpdate(src);
});

function Mount() {
  MountOrUpdate()
}

function MountOrUpdate(currentEntry?: string) {
  const mountPoint = document.getElementById('embedded-gallery-overlay-mount');
  if (mountPoint == null) {
    throw new Error("No mount point element found");
  }

  const contextElement = document.getElementById("embedded-gallery-context");
  if (contextElement == null) {
    throw new Error("No context element found");
  }

  let props = JSON.parse(contextElement.textContent);

  if (currentEntry != undefined) {
    props.currentEntry = currentEntry;
  }

  props.incrementer = new Date();

  render(h(EmbeddedGallery, props), mountPoint);
}

export {
  Mount
}
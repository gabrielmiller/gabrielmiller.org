import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import IconArrowLeftCircle from './IconArrowLeftCircle';
import IconArrowRightCircle from './IconArrowRightCircle';
import IconXMarkCircle from './IconXMarkCircle';
import AsyncImage from './AsyncImage';
import IconDownTray from './IconDownTray';
import AsyncVideo from './AsyncVideo';
import IconCamera from './IconCamera';
import IconVideoCamera from './IconVideoCamera';

interface IEmbeddedGalleryProps {
  currentEntry: string,
  entries: IEntry[],
  incrementer: Date
}

interface IEntry {
  date: string,
  label: string,
  original: string,
  thumb1x: string,
  thumb2x: string,
  thumb4x: string,
  video?: string,
  web: string
}

interface IEntryMap {
  [key: string]: number
}

const clickableElements = new Set([
  "BUTTON",
  "SVG",
  "PATH",
  "IMG"
])

const EmbeddedGallery: FunctionComponent<IEmbeddedGalleryProps> = ({ currentEntry, entries, incrementer }) => {
  const [currentEntryIndex, setCurrentEntryIndex] = useState(0);
  const [mediaMode, setMediaMode] = useState("Image");
  const [isVisible, setIsVisible] = useState(false);
  const [thumbToIndexMap, setThumbToIndexMap] = useState<IEntryMap>({});
  const isActive = () => {
    return currentEntry !== undefined;
  }

  const closeGallery = (event: any) => {
    setIsVisible(false)
    event.preventDefault();
  }

  const maybeCloseGallery = (event: any) => {
    const targetTag = event.target?.tagName;
    if (targetTag === null || targetTag == undefined) {
      return;
    }

    if (clickableElements.has(targetTag.toUpperCase())) {
      return;
    }

    closeGallery(event);
  }

  const maybeSwitchMediaMode = (nextEntryIndex: number) => {
    if (entries[nextEntryIndex].video !== undefined) {
      return;
    }

    setMediaMode("Image");
  };

  const navigateToNextEntry = (event: any) => {
    event.preventDefault();
    const nextEntryIndex = currentEntryIndex + 1;

    maybeSwitchMediaMode(nextEntryIndex);
    setCurrentEntryIndex(nextEntryIndex);
  };

  const navigateToPrevEntry = (event: any) => {
    event.preventDefault();
    const nextEntryIndex = currentEntryIndex - 1;

    maybeSwitchMediaMode(nextEntryIndex);
    setCurrentEntryIndex(nextEntryIndex);
  };

  const validateCanNavigateToNextEntry = (): boolean => {
    return currentEntryIndex !== (entries.length - 1);
  };

  const validateCanNavigateToPrevEntry = (): boolean => {
    return currentEntryIndex != 0;
  };

  useEffect(() => {
    const entryMap: IEntryMap = {};
    for (let i = 0; i < entries.length; i++) {
      entryMap[entries[i].thumb1x] = i;
    }

    setThumbToIndexMap(entryMap);
  }, []);

  useEffect(() => {
    if (isActive()) {
      const currentEntryIndex = thumbToIndexMap[currentEntry];
      setCurrentEntryIndex(currentEntryIndex);
    }
  }, [currentEntry]);

  useEffect(() => {
    const keyboardListener = (event: any) => {
      if (event.code === "Escape") {
        setIsVisible(false);
      } else if (event.code === "ArrowLeft" && validateCanNavigateToPrevEntry()) {
        navigateToPrevEntry(event);
      } else if (event.code === "ArrowRight" && validateCanNavigateToNextEntry()) {
        navigateToNextEntry(event);
      }
    };

    document.addEventListener("keydown", keyboardListener);

    return () => {
      document.removeEventListener("keydown", keyboardListener);
    };

  }, [currentEntryIndex]);

  useEffect(() => {
    if (!isActive()) {
      return;
    }

    // Manually reset the current entry index to avoid showing stale media
    // when exiting and re-entering the viewer
    const currentEntryIndex = thumbToIndexMap[currentEntry];
    setCurrentEntryIndex(currentEntryIndex);
    maybeSwitchMediaMode(currentEntryIndex);

    setIsVisible(true);
  }, [incrementer])

  return (
    <div>
      <div class={isVisible ? "visible" : "hidden"} id="embedded-gallery-backdrop"></div>
      <div class={isVisible ? "visible" : "hidden"} id="embedded-gallery-overlay" onClick={(event) => maybeCloseGallery(event)}>
        {isActive() &&
          <div class="gallery-container">
            <div class="media-container">
              {mediaMode == "Image" && (
                <AsyncImage src={entries[currentEntryIndex].web} />
              )}
              {mediaMode == "Video" && (
                <AsyncVideo poster={entries[currentEntryIndex].web} src={entries[currentEntryIndex].video!} />
              )}
            </div>
            <div
              class="controls-top-right"
            >
              <div class="top-row">
                <a
                  class="control-download-original"
                  href={entries[currentEntryIndex].original}
                  target="_blank"
                  title="View original">
                  <IconDownTray />
                </a>
                {mediaMode == "Image" && (
                  <button
                    class="control-change-mode"
                    disabled={entries[currentEntryIndex].video == undefined}
                    onClick={() => setMediaMode("Video")}
                    title="Change media mode"
                    type="button">
                    <IconVideoCamera />
                  </button>
                )}
                {mediaMode == "Video" && (
                  <button
                    class="control-change-mode"
                    onClick={() => setMediaMode("Image")}
                    title="Change media mode"
                    type="button">
                    <IconCamera />
                  </button>
                )}
                <button
                  class="control-close-viewer"
                  onClick={(event) => closeGallery(event)}
                  title="Close viewer"
                  type="button">
                  <IconXMarkCircle />
                </button>
              </div>
              <div class="bottom-row">
                {currentEntryIndex + 1} / {entries.length}
              </div>
            </div>
            <button
              class="control-navigate-previous"
              disabled={!validateCanNavigateToPrevEntry()}
              onClick={(event) => navigateToPrevEntry(event)}
              title="Navigate to previous entry"
              type="button">
              <IconArrowLeftCircle />
            </button>
            <button
              class="control-navigate-next"
              disabled={!validateCanNavigateToNextEntry()}
              onClick={(event) => navigateToNextEntry(event)}
              title="Navigate to next entry"
              type="button">
              <IconArrowRightCircle />
            </button>
            {entries[currentEntryIndex].label !== "" && (
              <div class="label">
                <p>
                  [{entries[currentEntryIndex].date}] {entries[currentEntryIndex].label}
                </p>
              </div>
            )}
          </div>
        }
      </div>
    </div>
  );
};

export default EmbeddedGallery;
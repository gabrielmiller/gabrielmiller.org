import { FunctionComponent } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import AsyncImage from './AsyncImage';
import IconInfo from './IconInfo';
import IconFixedHeight from './IconFixedHeight';
import IconFixedWidth from './IconFixedWidth';
import IconFullScreen from './IconFullScreen';
import IconArrowLeftCircle from './IconArrowLeftCircle';
import IconArrowRightCircle from './IconArrowRightCircle';

interface IAlbumEntry {
    filename: string;
    isLoaded: boolean;
    metadata: IAlbumEntryMetadata;
    url?: string;
}

interface IAlbumEntryMetadata {
    description?: string;
}

enum ViewModes {
    FixedHeight='Fixed height',
    FixedWidth='Fixed width',
    OriginalSize='Original size'
}

const AlbumViewer: FunctionComponent = () => {
    const [AlbumTitle, setAlbumTitle] = useState('');
    const [AlbumToken, setAlbumToken] = useState('');
    const [isIndexLoaded, setIsIndexLoaded] = useState(false);
    const [isIndexLoading, setIsIndexLoading] = useState(false);
    const [index, setIndex] = useState<IAlbumEntry[]>([]);
    const [currentEntryIndex, setCurrentEntryIndex] = useState(0);
    const [isPageLoading, setIsPageLoading] = useState(false);
    const [viewMode, setViewMode] = useState<ViewModes>(ViewModes.FixedWidth);
    const [isErrorShown, setIsErrorShown] = useState(false);
    const [isInfoShown, setIsInfoShown] = useState(true);

    const apiDomain = "https://api."+window.location.host;
    const entriesPerPage = 12;

    const buildBasicAuthHeader = (title: string, token: string): string => {
        return 'Basic '+btoa(title+":"+token);
    }

    const changeViewMode = () => {
        let next: ViewModes;
        switch(viewMode) {
            case ViewModes.FixedWidth:
                next = ViewModes.OriginalSize;
                break;
            case ViewModes.OriginalSize:
                next = ViewModes.FixedHeight;
                break;
            case ViewModes.FixedHeight:
                next = ViewModes.FixedWidth;
                break;
        }
        setViewMode(next);
    }

    const loadIndex = (title: string, token: string) => {
        setIsIndexLoading(true);
        const headers = new Headers();
        headers.append('Authorization', buildBasicAuthHeader(title, token));
        fetch(`${apiDomain}/album`, { method: 'GET', headers }).then(function(response) {
            if (response.status !== 200) {
                setIsErrorShown(true);
                return;
            }

            response.json().then((body) => {
                const index: IAlbumEntry[] = [];
                for (const entry of body) {
                    entry.isLoaded = false;
                    index.push(entry);
                }
                setIndex(index);
                setIsErrorShown(false);
                setIsIndexLoaded(true);
            });
        }).then(() => {
            setAlbumTitle(title);
            setAlbumToken(token);
        }, () => {
            setIsErrorShown(true);
        }).finally(() => {
            setIsIndexLoading(false);
        });
    };

    const handleSubmission = (event) => {
        event.preventDefault();

        const title = event.target.children['album-title'].value;
        const token = event.target.children['album-token'].value;

        loadIndex(title, token);
    }

    const loadPage = () => {
        let entryIndex = currentEntryIndex+1;
        setIsPageLoading(true);
        const headers = new Headers();
        headers.append('Authorization', buildBasicAuthHeader(AlbumTitle, AlbumToken));
        fetch(`${apiDomain}/entries?page=${Math.ceil(entryIndex/entriesPerPage)}&perPage=${entriesPerPage}`, { method: 'GET', headers }).then(function(response) {
            if (response.status !== 200) {
                return;
            }

            response.json().then((body) => {
                const newIndex = [...index];

                for (const url of body) {
                    newIndex[entryIndex-1].url = url;
                    newIndex[entryIndex-1].isLoaded = true;
                    entryIndex++;
                }

                setIndex(newIndex);
            });

        }).finally(() => {
            setIsPageLoading(false);
        });
    };

    const navigateToNextEntry = () => {
        setCurrentEntryIndex(currentEntryIndex+1);
    };

    const navigateToPrevEntry = () => {
        setCurrentEntryIndex(currentEntryIndex-1);
    };

    const validateCanNavigateToNextEntry = (): boolean => {
        return currentEntryIndex !== (index.length-1);
    };

    const validateCanNavigateToPrevEntry = (): boolean => {
        return currentEntryIndex != 0;
    };

    useEffect(() => {
        if (isIndexLoaded && !isPageLoading && !index[currentEntryIndex].isLoaded) {
            loadPage();
        }

        const kbListener = (event) => {
            if (event.code === "ArrowLeft" && validateCanNavigateToPrevEntry()) {
                navigateToPrevEntry();
            } else if (event.code === "ArrowRight" && validateCanNavigateToNextEntry()) {
                navigateToNextEntry();
            }
        };

        document.addEventListener("keydown", kbListener);

        return () => {
            document.removeEventListener("keydown", kbListener);
        };

    }, [currentEntryIndex, isIndexLoaded]);

    useEffect(() => {
        const queryParams = new URLSearchParams(location.search);
        if (!queryParams.has('title') || !queryParams.has('token')) {
            return;
        }

        const title = queryParams.get("title");
        const token = queryParams.get("token");

        loadIndex(title, token);
    }, [])

    return (
        <div class="album-viewer">
            {!isIndexLoaded && !isIndexLoading && (
                <form onSubmit={(e) => handleSubmission(e) }>
                    {isErrorShown && (
                        <span>Either the credentials you specified were invalid or the system is experiencing technical difficulties. Please try again.</span>
                    )}
                    <input
                        autoFocus
                        id="album-title"
                        placeholder="Enter album title"
                        type="text">
                    </input>
                    <input
                        id="album-token"
                        placeholder="Enter token"
                        type="text">
                    </input>
                    <button disabled={isIndexLoading} type="submit">View content &gt;</button>
                </form>
            )}

            {!isIndexLoaded && isIndexLoading && (
                <span class="loader"></span>
            )}

            {isIndexLoaded && (
                <>
                    <div class={`album-container ${viewMode.replace(" ","-").toLowerCase()}`}>
                        {!('url' in index[currentEntryIndex]) && (
                            <span class="loader"></span>
                        )}
                        {('url' in index[currentEntryIndex]) && (
                            <AsyncImage src={index[currentEntryIndex].url} />
                        )}
                    </div>
                    <button
                        class="control-change-view-mode"
                        onClick={() => changeViewMode()}
                        title="Change view mode.">
                        {
                            {
                                [ViewModes.FixedHeight]: <IconFixedHeight />,
                                [ViewModes.FixedWidth]: <IconFixedWidth />,
                                [ViewModes.OriginalSize]: <IconFullScreen />,
                            }[viewMode]
                        }
                    </button>
                    <button
                        class="control-show-information"
                        onClick={() => setIsInfoShown(!isInfoShown)}
                        title="Toggle more information"
                        type="button">
                        <IconInfo />
                    </button>
                    <button
                        class="control-navigate-previous"
                        disabled={!validateCanNavigateToPrevEntry()}
                        onClick={() => navigateToPrevEntry()}
                        title="Navigate to previous entry"
                        type="button">
                        <IconArrowLeftCircle />
                    </button>
                    <button
                        class="control-navigate-next"
                        disabled={!validateCanNavigateToNextEntry()}
                        onClick={() => navigateToNextEntry()}
                        title="Navigate to next entry"
                        type="button">
                        <IconArrowRightCircle />
                    </button>
                    {isInfoShown && (
                        <div class="information">
                            {index[currentEntryIndex].metadata?.description}
                        </div>
                    )}
                </>
            )}
        </div>
    );
};

export default AlbumViewer;
import React from 'react';

interface IStoryEntry {
    filename: string;
    isLoaded: boolean;
    metadata: any;
    url?: string;
}

const StoryViewer: React.FC = () => {
    const [storyTitle, setStoryTitle] = React.useState('');
    const [storyToken, setStoryToken] = React.useState('');
    const [isIndexLoaded, setIsIndexLoaded] = React.useState(false);
    const [isIndexLoading, setIsIndexLoading] = React.useState(false);
    const [index, setIndex] = React.useState<IStoryEntry[]>([]);
    const [currentEntryIndex, setCurrentEntryIndex] = React.useState(0);
    const [isPageLoading, setIsPageLoading] = React.useState(false);

    const apiDomain = "https://api."+window.location.host;
    const entriesPerPage = 2;

    const getBasicAuthHeader = (): string => {
        return 'Basic '+btoa(storyTitle+":"+storyToken);
    }

    const loadIndex = (event) => {
        event.preventDefault();

        setIsIndexLoading(true);

        const headers = new Headers();
        headers.append('Authorization', getBasicAuthHeader());
        fetch(`${apiDomain}/story`, { method: 'GET', headers }).then(function(response) {
            if (response.status !== 200) {
                return;
            }

            response.json().then((body) => {
                const index: IStoryEntry[] = [];
                for (const entry of body) {
                    entry.isLoaded = false;
                    index.push(entry);
                }
                setIndex(index);
                setIsIndexLoaded(true);
            });
        }).finally(() => {
            setIsIndexLoading(false);
        });
    }

    const loadPage = () => {
        let entryIndex = currentEntryIndex+1;
        setIsPageLoading(true);
        const headers = new Headers();
        headers.append('Authorization', getBasicAuthHeader());
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
    }

    React.useEffect(() => {
        if (!isIndexLoaded) {
            return;
        }

        if (isPageLoading) {
            return;
        }

        if (index[currentEntryIndex].isLoaded) {
            return;
        }
        loadPage();
    }, [currentEntryIndex, isIndexLoaded]);

    return (
        <>
            {!isIndexLoaded && (
                <form onSubmit={loadIndex}>
                    <input autoFocus disabled={isIndexLoading} onChange={(e) => setStoryTitle(e.target.value)} placeholder="story title" type="text"></input>
                    <input disabled={isIndexLoading} onChange={(e) => setStoryToken(e.target.value)} placeholder="token" type="text"></input>
                    <button disabled={isIndexLoading} type="submit">Go!</button>
                </form>
            )}

            {isIndexLoaded && (
                <>
                    <div>
                        <b>Index loaded successfully!</b>
                        <pre>{JSON.stringify(index, null, 2) }</pre>
                    </div>
                    {!('url' in index[currentEntryIndex]) && (
                        <span>
                            Loading...
                        </span>
                    )}
                    {('url' in index[currentEntryIndex]) && (
                        <img src={index[currentEntryIndex].url}></img>
                    )}
                    <div>
                        <button disabled={currentEntryIndex == 0} onClick={() => setCurrentEntryIndex(currentEntryIndex-1)} type="button">&lt; Prev</button>
                        <button disabled={currentEntryIndex === (index.length-1)} onClick={() => setCurrentEntryIndex(currentEntryIndex+1)} type="button">Next &gt;</button>
                    </div>
                </>
            )}
        </>
    );
};

export default StoryViewer;
import React from 'react';

const StoryViewer: React.FC = () => {
    const [storyTitle, setStoryTitle] = React.useState('');
    const [storyToken, setStoryToken] = React.useState('');
    const [isIndexLoaded, setisIndexLoaded] = React.useState(false);
    const [isIndexLoading, setIsIndexLoading] = React.useState(false);

    const loadIndex = (event) => {
        event.preventDefault();

        const apiDomain = "https://api."+window.location.host;
        const headers = new Headers();
        headers.append('Authorization', 'Basic '+btoa(storyTitle+":"+storyToken));

        setIsIndexLoading(true);

        fetch(`${apiDomain}/story`, { method: 'GET', headers }).then(function(response) {
            if (response.status === 200) {
                setisIndexLoaded(true);
            }
        }).finally(() => {
            setIsIndexLoading(false);
        });
    }

    React.useEffect(() => {
        if (isIndexLoaded) {
            console.log("should fetch paginated images");
        }
    }, [isIndexLoaded]);

    return (
        <>
            {!isIndexLoaded && (
                <form onSubmit={loadIndex}>
                    <input disabled={isIndexLoading} onChange={(e) => setStoryTitle(e.target.value)} placeholder="story title" type="text"></input>
                    <input disabled={isIndexLoading} onChange={(e) => setStoryToken(e.target.value)} placeholder="token" type="text"></input>
                    <button disabled={isIndexLoading} type="submit">Go!</button>
                </form>
            )}

            {isIndexLoaded && (
                <div>
                    Index loaded successfully!
                </div>
            )}
        </>
    );
};

export default StoryViewer;
import React from 'react';
import ReactDOM from 'react-dom/client';
import StoryViewer from './StoryViewer';

const root = ReactDOM.createRoot(document.getElementById('app-mount')!);
root.render(<StoryViewer />);

document.getElementById("initial-loader")!.remove();
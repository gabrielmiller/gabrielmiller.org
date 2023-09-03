import * as React from "react"

const Navigation = () => (
    <nav>
        <div>L. Gabriel Miller</div>
        <input id="nav-toggle-state" style={{ display: 'none'} as React.CSSProperties} type="checkbox"></input>
        <label id="nav-toggle" htmlFor="nav-toggle-state" role="button">
            <svg viewBox="0 0 100 80" width="40" height="40">
                <rect width="100" height="20"></rect>
                <rect y="30" width="100" height="20"></rect>
                <rect y="60" width="100" height="20"></rect>
            </svg>
        </label>
        <ul>
            <li>
                <a href="/">About</a>
            </li>
            <li>
                <a href="/archive.html">Blog</a>
            </li>
        </ul>
    </nav>
)

export default Navigation
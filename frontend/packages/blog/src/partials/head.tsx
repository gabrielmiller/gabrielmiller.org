import * as React from "react"

// @ts-ignore
const Head = ({ children }) => (
    <>
        <title>Gabe Miller</title>
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
        <link rel="manifest" href="/site.webmanifest" />
        {/* @ts-ignore */}
        <link rel="stylesheet" href="/styles.css"/>
        <meta name="viewport" content="width=device-width" />
        { children }
    </>
)

export default Head
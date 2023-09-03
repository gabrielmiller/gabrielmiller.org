import * as React from "react"
import { PageProps, graphql } from 'gatsby'
import Header from "../partials/head"
import Navigation from "../partials/navigation"
import { IPost } from "../services/post"

interface IMostRecentPostContainer {
    allMarkdownRemark: {
        nodes: IPost[]
    }
}

export const Head = Header
const IndexPage: React.FC<PageProps<IMostRecentPostContainer>> = ({ data }) => {
    const mostRecentPost: IPost = data.allMarkdownRemark.nodes[0];

    return (
        <div className="container">
            <Navigation />
            <main>
            <p className="callout">
                Check out my most recent article: <a href={`/posts/${mostRecentPost.frontmatter.slug}.html`}>{mostRecentPost.frontmatter.title}</a>
                <br />
            </p>
            <img alt="a photo of the author" className="avatar" src="avatar.jpg" />
            <p>Hi there! My name is Gabe.</p>
            <p>I'm interested in most things web-development, databases, security, and GIS. I work on the software engineering team at <a href="https://www.jazzhr.com">JazzHR</a>, which was formerly known as <em>Jazz</em> and before that <em>The Resumator</em>. I'm a full-stack engineer and gravitate toward front-end development, testing, and data.</p>
            <p>Growing up I played PC games and as a result was exposed to building computers at a young age. Despite that I was a late entrant to the software industry. I'm a self-taught software engineer and hold a degree in environmental studies.</p>
            <p>I am a proponent of open-source software and appreciate its many communities.</p>
            <p>In my free time I enjoy tinkering with personal software projects, which as of late has been moving my data and usage of cloud services to self-hosted alternatives on in-house hardware. I am a dedicated recreational athlete; I regularly run, row, and boulder. I am a hobbyist woodworker--closer to the ornate end of the spectrum--utilizing both hand and power tools. I also enjoy gardening.</p>
            <p>I intend to publish some of my software-related thoughts--and maybe some other miscellaneous stuff--on this website.</p>
            <p>This website is comprised of personal thoughts, work, and projects unless otherwise noted. None of the opinions expressed within represent those of my employer.</p>
            <p>You can find my current resume <a href="lgabrielmiller.pdf">here</a> which has my contact information in it. Additionally, you can view my github account <a href="https://github.com/gabrielmiller/">here</a>.</p>
            </main>
        </div>
    )
}

export const query = graphql`
{
    allMarkdownRemark(limit: 1, sort: {frontmatter: {date: DESC}}) {
        nodes {
            frontmatter {
                date
                title
                slug
            }
        }
    }
}
`

export default IndexPage
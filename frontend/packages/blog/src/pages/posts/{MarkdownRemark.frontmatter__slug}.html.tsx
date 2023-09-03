import * as React from "react"
import type { PageProps } from "gatsby"
import { graphql } from 'gatsby'
import Header from "../../partials/head"
import Navigation from "../../partials/navigation"
import { IPost } from "../../services/post"
import dasherize from "../../services/dasherize"

interface IPostContainer {
    markdownRemark: IPost
}

export const Head = Header
const PostPage: React.FC<PageProps<IPostContainer>> = ({ data }) => {
    const article: IPost = data.markdownRemark

    return (
        <div className="container">
            <Navigation />
            <main>
                <h1>{ article.frontmatter.title }</h1>
                <p>
                    Published {article.frontmatter.date}
                { article.frontmatter.tags !== null && (
                    <>
                        <br/><span>Tags:</span>{ article.frontmatter.tags.sort().map((tag) => <a className="tag" href={`/archive.html#${dasherize(tag)}`}>{tag}</a>) }
                    </>
                ) }
                </p>
                <div dangerouslySetInnerHTML={{ __html: article.html }}></div>
            </main>
        </div>
    )
}

export const query = graphql`
query ($id: String!) {
    markdownRemark(id: { eq: $id }) {
        html
        frontmatter {
            date(formatString: "MMMM DD, YYYY")
            title
            tags
        }
    }
}
`

export default PostPage
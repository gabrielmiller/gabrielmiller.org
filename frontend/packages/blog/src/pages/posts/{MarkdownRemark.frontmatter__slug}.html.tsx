import * as React from "react"
import type { PageProps } from "gatsby"
import { graphql } from 'gatsby'
import Header from "../../partials/head"
import Navigation from "../../partials/navigation"
import { IPost } from "../../services/post"

interface IPostContainer {
    markdownRemark: IPost
}

export const Head = Header
const PostPage: React.FC<PageProps<IPostContainer>> = ({ data }) => {
    const article: IPost = data.markdownRemark

    return (
        <div>
            <Navigation />
            <h2>Article - { article.frontmatter.title }</h2>
            { article.frontmatter.tags !== null && (
                <p>
                    <span>Tags:</span>{ article.frontmatter.tags.map((tag) => <span>{tag}</span>) }
                </p>
            ) }
            <p>Published {article.frontmatter.date}</p>
            <div dangerouslySetInnerHTML={{ __html: article.html }}></div>
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
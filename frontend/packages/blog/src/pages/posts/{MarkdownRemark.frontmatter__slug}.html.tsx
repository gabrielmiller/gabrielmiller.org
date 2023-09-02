import * as React from "react"
import type { HeadFC, PageProps } from "gatsby"
import { graphql } from 'gatsby'
import { IPost } from "../../services/post"

interface IPostContainer {
  markdownRemark: IPost
}

const PostPage: React.FC<PageProps<IPostContainer>> = ({ data }) => {
  const article: IPost = data.markdownRemark

  return (
    <div>
      <a href="/">Back to list</a>
      <h2>Article - {article.frontmatter.title}</h2>
      <div dangerouslySetInnerHTML={{ __html: article.html }}></div>
    </div>
  )
}

export const Head: HeadFC<IPostContainer> = ({ data }) => {
  const article: IPost = data.markdownRemark
  return (
    <title>{article.frontmatter.title}</title>
  )
}

export const query = graphql`
query ($id: String!) {
  markdownRemark(id: { eq: $id }) {
    html
    frontmatter {
      date(formatString: "MMMM DD, YYYY")
      title
    }
  }
}
`

export default PostPage
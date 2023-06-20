import * as React from "react"
import type { HeadFC, PageProps } from "gatsby"
import { graphql } from 'gatsby'
import { IPost } from "../../services/post";

const PostPage: React.FC<PageProps> = ({data}) => {
  const article: IPost = (data as any).markdownRemark;

  return (
    <div>
      <a href="/">Back to list</a>
      <h2>Article - {article.frontmatter.title}</h2>
      <div dangerouslySetInnerHTML={{ __html: article.html }}>
      </div>
    </div>
  )
}

export default PostPage;

export const Head: HeadFC = ({ data }) => {
  const article: IPost = (data as any).markdownRemark;
  return (
    <title>{article.frontmatter.title}</title>
  );
};

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
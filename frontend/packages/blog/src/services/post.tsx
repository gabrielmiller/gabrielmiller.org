export interface IPost {
    frontmatter: {
      date: string,
      slug: string,
      title: string,
      tags: string[]
    },
    html: string,
}
export interface IPost {
    frontmatter: {
      date: string,
      slug?: string,
      title: string,
    },
    html: string,
}
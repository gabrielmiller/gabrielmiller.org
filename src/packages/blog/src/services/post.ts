export interface IPost extends IPostMeta {
    html: string,
}

export interface IPostMeta {
  frontmatter: {
    date: string,
    slug: string,
    title: string,
    tags: string[]
  }
}
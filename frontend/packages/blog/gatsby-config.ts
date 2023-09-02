import type { GatsbyConfig } from "gatsby";

const config: GatsbyConfig = {
  siteMetadata: {
    title: `Gabe Miller`,
    siteUrl: `https://www.gabrielmiller.org`
  },
  graphqlTypegen: true,
  plugins: [
    {
      resolve: 'gatsby-source-filesystem',
      options: {
        "name": "posts",
        "path": "./src/posts/"
      },
      __key: "posts"
    },
    {
      resolve: `gatsby-transformer-remark`,
      options: {},
    },
    "gatsby-plugin-no-javascript-utils"]
};

export default config;

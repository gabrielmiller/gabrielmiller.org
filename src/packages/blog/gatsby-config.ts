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
            resolve: 'gatsby-source-filesystem',
            options: {
                "name": "recipes",
                "path": "./src/recipes/"
            },
            __key: "recipes"
        },
        `gatsby-plugin-sharp`,
        {
            resolve: `gatsby-transformer-remark`,
            options: {
                plugins: [
                    {
                        resolve: `gatsby-remark-images`,
                        options: {
                            maxWidth: 720, // matches 40em@18px of current blog
                        },
                    },
                ],
            },
        },
        {
            resolve: `gatsby-plugin-no-javascript-utils`,
            options: {
                noScript: true,
                noSourcemaps: true,
                removeGeneratorTag: true,
                removeHeadDataAttrs: true,
                noInlineStyles: false,
                removeGatsbyAnnouncer: true,
            }
        }
    ]
};

export default config;

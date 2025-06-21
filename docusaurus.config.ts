import { themes as prismThemes } from "prism-react-renderer";
import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: "AirPrint Bridge",
  tagline: "Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS",
  favicon: "img/favicon.svg",

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: "https://sapireli.github.io",
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: "/AirPrint_Bridge/",

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: "sapireli", // Usually your GitHub org/user name.
  projectName: "AirPrint_Bridge", // Usually your repo name.

  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      "classic",
      {
        docs: {
          sidebarPath: "./sidebars.ts",
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: "https://github.com/sapireli/AirPrint_Bridge/tree/main/",
        },
        blog: {
          showReadingTime: false,
          feedOptions: {
            type: ["rss", "atom"],
            xslt: true,
            title: "AirPrint Bridge Releases",
            description: "Release notes and changelog for AirPrint Bridge",
          },
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: "https://github.com/sapireli/AirPrint_Bridge/tree/main/",
          // Useful options to enforce releases best practices
          onInlineTags: "warn",
          onInlineAuthors: "warn",
          onUntruncatedBlogPosts: "warn",
        },
        theme: {
          customCss: "./src/css/custom.css",
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: "img/airprint-bridge-social-card.jpg",
    navbar: {
      title: "AirPrint Bridge",
      logo: {
        alt: "AirPrint Bridge Logo",
        src: "img/logo.svg",
      },
      items: [
        {
          type: "docSidebar",
          sidebarId: "tutorialSidebar",
          position: "left",
          label: "Documentation",
        },
        { to: "/blog", label: "Releases", position: "left" },
        {
          href: "https://github.com/sapireli/AirPrint_Bridge",
          label: "GitHub",
          position: "right",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Documentation",
          items: [
            {
              label: "Getting Started",
              to: "/docs/intro",
            },
            {
              label: "Installation",
              to: "/docs/installation",
            },
            {
              label: "Troubleshooting",
              to: "/docs/troubleshooting",
            },
          ],
        },
        {
          title: "Community",
          items: [
            {
              label: "GitHub Issues",
              href: "https://github.com/sapireli/AirPrint_Bridge/issues",
            },
            {
              label: "GitHub Discussions",
              href: "https://github.com/sapireli/AirPrint_Bridge/discussions",
            },
            {
              label: "Star on GitHub",
              href: "https://github.com/sapireli/AirPrint_Bridge",
            },
          ],
        },
        {
          title: "More",
          items: [
            {
              label: "Releases",
              to: "/blog",
            },
            {
              label: "License",
              to: "/docs/license",
            },
            {
              label: "Contributing",
              to: "/docs/contributing",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} AirPrint Bridge. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ["bash", "json"],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

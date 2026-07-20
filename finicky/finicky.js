// Finicky browser router config (v4). Symlinked to ~/.finicky.js.
// Default to Chrome; route Temporal Cloud to Island Browser.
export default {
  defaultBrowser: "Google Chrome",
  options: {
    hideIcon: true,
  },
  handlers: [
    {
      match: [
        "cloud.temporal.io",
        "cloud.temporal.io/*",
        "*.cloud.temporal.io/*",
        "*.tmprl-test.cloud"
      ],
      browser: "Island",
    },
    {
      match: [
        "app.notion.com/p/temporalio",
        "app.notion.com/p/temporalio/*"
      ],
      browser: { name: "Google Chrome", profile: "Default" },
    },
    {
      match: [
        "github.com/temporalio/temporal",
        "github.com/temporalio/temporal/*",
        "github.com/dandavison/log/issues*"
      ],
      browser: { name: "Google Chrome", profile: "Default" },
    },
  ],
};

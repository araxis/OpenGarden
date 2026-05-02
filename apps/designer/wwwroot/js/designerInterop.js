window.openGardenDesigner = {
  copyText: async (text) => {
    if (!navigator.clipboard) {
      return false;
    }

    await navigator.clipboard.writeText(text);
    return true;
  },
  prefersDarkMode: () => window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
};

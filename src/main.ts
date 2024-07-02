import "glint-environment-gxt";
import "decorator-transforms/globals";
import "./style.css";

import { renderComponent, type ComponentReturnType } from "@lifeart/gxt";
// @ts-ignore unknown module import
import App from "./App.gts";

if (import.meta.env.DEV) {
  // @ts-ignore wrong dts
  await import('@lifeart/gxt/ember-inspector');
}

renderComponent(
  new App({}) as unknown as ComponentReturnType,
  document.getElementById("app")!
);

try {
  const rgb2hex = (rgb: string) => `#${rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/).slice(1).map(n => parseInt(n, 10).toString(16).padStart(2, '0')).join('')}`
  const color = rgb2hex(window.getComputedStyle(document.body).backgroundColor);
  Telegram.WebApp.setHeaderColor(color);
  Telegram.WebApp.setBackgroundColor(color);
} catch(e) {
  // fine;
}
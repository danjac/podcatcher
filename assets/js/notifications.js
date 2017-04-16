export const notify = (msg, style) => {
  const $callout = $(`
  <div class="callout ${style || ''}">
    <p>${msg}</p>
  </div>
  `);
  $('#notifications').append($callout);
  window.setTimeout(() => $callout.remove(), 3000);
};

export const success = (msg) => notify(msg, "success");
export const info = (msg) => notify(msg, "info");

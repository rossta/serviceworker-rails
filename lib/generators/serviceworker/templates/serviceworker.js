function onInstall() {
  console.log('[Serviceworker]', "Installing!");
}

function onActivate() {
  console.log('[Serviceworker]', "Activating!");
}

function onFetch() {
}

self.addEventListener('install', onInstall);
self.addEventListener('activate', onActivate);
self.addEventListener('fetch', onFetch);

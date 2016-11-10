// function onInstall(event) {
//   console.log('[Serviceworker]', "Installing!", event);
//   event.waitUntil(
//     caches.open('cached-assets-v1').then(function prefill(cache) {
//       return cache.addAll([
//         '<%#= asset_path "application.js" %>',
//         '<%#= asset_path "application.css" %>',
//         '/offline.html'
//       ]);
//     })
//   );
// }
//
// function onActivate(event) {
//   console.log('[Serviceworker]', "Activating!", event);
//   event.waitUntil(
//     caches.keys().then(function(cacheNames) {
//       return Promise.all(
//         cacheNames.filter(function(cacheName) {
//           // Return true if you want to remove this cache,
//           // but remember that caches are shared across
//           // the whole origin
//         }).map(function(cacheName) {
//           return caches.delete(cacheName);
//         })
//       );
//     })
//   );
// }
//
// function onFetch(event) {
//   // Fetch from cache, fallback to network
//   event.respondWith(
//     caches.match(event.request).then(function(response) {
//       return response || fetch(event.request);
//     })
//   );
//
//   // See https://jakearchibald.com/2014/offline-cookbook/#on-network-response for more examples
// }
//
// self.addEventListener('install', onInstall);
// self.addEventListener('activate', onActivate);
// self.addEventListener('fetch', onFetch);

// function onInstall(event) {
//   console.log('[Serviceworker]', "Installing!", event);
//   event.waitUntil(
//     caches.open('cached-assets-v1').then(function prefill(cache) {
//       return cache.addAll([
//         '<%%= asset_path "application.js" %>',
//         '<%%= asset_path "application.css" %>',
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
//            return key.indexOf('v1') !== 0;
//         }).map(function(cacheName) {
//           return caches.delete(cacheName);
//         })
//       );
//     })
//   );
// }
//
// function onFetch(event) {
//   // Fetch from network, fallback to cached content, then offline.html for same-origin GET requests
//   var request = event.request;
//
//   if (!request.url.match(/^https?:\/\/example.com/) ) { return; }
//   if (request.method !== 'GET') { return; }
//
//   event.respondWith(
//     fetch(request)                                        // first, the network
//       .catch(function fallback() {
//          caches.match(request).then(function(response) {  // then, the cache
//            response || caches.match("/offline.html");     // then, /offline cache
//          })
//        })
//   );
//
//   // See https://jakearchibald.com/2014/offline-cookbook/#on-network-response for more examples
// }
//
// self.addEventListener('install', onInstall);
// self.addEventListener('activate', onActivate);
// self.addEventListener('fetch', onFetch);

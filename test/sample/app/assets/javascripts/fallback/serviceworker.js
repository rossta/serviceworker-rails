console.log('SW:', 'Hello from Fallback ServiceWorker!');

self.addEventListener('fetch', function(event) {
  console.log('SW:', 'fetching', event.request.url);
  return;
});

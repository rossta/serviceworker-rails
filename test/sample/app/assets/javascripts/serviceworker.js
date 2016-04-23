console.log('SW:', 'Hello from ServiceWorker!');

self.addEventListener('fetch', function(event) {
  console.log('SW:', 'fetching', event.request.url);
  return;
});

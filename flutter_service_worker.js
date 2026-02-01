'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "6194f623ba77b3f8744dd34d2029a013",
".git/config": "21b04f3929e58bf2ab2ae4aad2eabbf3",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "8af49badb913461478d40e4636f69e79",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "222931a60e5fc501999cc4e8e0940852",
".git/logs/refs/heads/main": "222931a60e5fc501999cc4e8e0940852",
".git/logs/refs/remotes/origin/main": "31a956a6391100e042558ff1f57d51d3",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/0b/97cf864a6c84f63bdd15d3b2160e6fb4dd6ad0": "3c169c6a1ec3b319d57c78a3f07a48c1",
".git/objects/13/5494582c95a1bd3925b2cdb24a1b11d2610522": "6f1764146980403f647799c92fb02c9d",
".git/objects/13/a4d39a76843d6f75542f16b6582d965fb96de9": "79bff573fc2e66ac9f52341de18ec89c",
".git/objects/23/dfdc458ce7a6e71ef8c6baf67351710b922751": "8ed96c1a699beb9423de132bb74aa104",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/3c/6c1a02bfc91ed574fe9b233ca6e544c453681e": "3fed996a638dcb62df2135492f55687c",
".git/objects/3d/2d9de92585e17326d42b6438d133836cf4236e": "527622a06f923cee2f6104162ae6025a",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/48/f4fa3264825f1ffc09db3cb1b7a959377cd847": "20a8553fb584f11cd0387b8dcf060813",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/57/e26ab567208baf890831b53440b59f1c37e503": "8465982d5dfb40933491244bdf41e2d5",
".git/objects/5b/2b1c7f143798c609ce407a676fbd8c12a97c3d": "bda249945a6504835bc8b8c419f9e2f2",
".git/objects/5c/09a85d90fec908d80c514a3f4bde549b579e68": "4a8dcb5b927e0fb8ecdfb7710517637e",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/70/0f29659ff76f78d2f6ed8ee08b7121f52df285": "58d8ab9cdec571e59d4e3ef8b6c2d67d",
".git/objects/77/97f7c6a7356b0d451d11a49925df854c22e978": "1aa892ecd25dc2a457249503f1fe6ea8",
".git/objects/78/34fa7c6b7ac623e7a16b45b1f07a85a8922929": "4cac4eaf721b37550ac047608cfc2721",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/80/fbe11c066ca75dce78d54202976bb320edfb91": "85f46616601e27bc1751fdcad996cebc",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/8e/21753cdb204192a414b235db41da6a8446c8b4": "1e467e19cabb5d3d38b8fe200c37479e",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/96/0f0f44bc01963228edd45a8cd396d5e0913c21": "9a8343e6fd4e584c367ae4555a27ba72",
".git/objects/98/6bda05db62527ba51561a7919cc99edf244c9c": "f1b06baefe5b33c8b86bcf433494dc94",
".git/objects/9e/cb281e6202479654b859e581766cb3363c1485": "049313cfe307a8483280d9463b951aa8",
".git/objects/a0/24f8686e9758e5d8899f778709bf1756a24d25": "dc1aaad53e4dd1e786ddefbc605bf84f",
".git/objects/a7/3f4b23dde68ce5a05ce4c658ccd690c7f707ec": "ee275830276a88bac752feff80ed6470",
".git/objects/aa/ff4140bceb8619bb7907f6932adf19ba5569b9": "d8eb1d53d4de8ec23f06290ac80d03d8",
".git/objects/ab/c7d0508ab1423e11268bc57c5d4b396502d4a7": "bd9b941116fe5b01ff6f78a35d89f5a2",
".git/objects/ad/7774dcd3634333e396b9a718f190756b41b39c": "fc25be3cc67070b7f61f6d9eeaf3df3e",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/bb/83fdc7a64037f9c60c9c0e2fdfce177562178e": "83723b2eb4179e045ed20291fe58a102",
".git/objects/bd/4feb4dc1b929f67d813da888e36f125829f11a": "e1939793c95180a779160fbf73b96ed6",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/c8/882b6c056ba1881dbcec231c375feb4a28bc15": "829ddfdb8508914623ab48365078c064",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/df/25ce2b7b8a665ab719c4108dec9ab66e7482b3": "7f7a4205755cda7f8b11f4d41a83a2a3",
".git/objects/e0/5f6c9f3370c77c6621a993faf85e0e2ad59ac8": "4dee335e970a4694509a12d6fae01fea",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/f8/996f9201b8accff63967ffb57f4ec9c52b0221": "8607f2bd4bf21e99d2112a85ce65a286",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/refs/heads/main": "2ac9afcea3eac4578eacd7264ae33db4",
".git/refs/remotes/origin/main": "2ac9afcea3eac4578eacd7264ae33db4",
"assets/AssetManifest.bin": "164a4ce3ba5f3b49f9848187a4fe0b03",
"assets/AssetManifest.bin.json": "34dd748765e51bc970ca1a5f7cb5af0a",
"assets/assets/logo.jpg": "91fe4e6899798f61853e4cc73bd593a5",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "3f22e260a3f6207631dbe5707bd11c55",
"assets/NOTICES": "06a4d62183ce1d1a7132c9ae5b30220c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.jpg": "91fe4e6899798f61853e4cc73bd593a5",
"favicon.png": "91fe4e6899798f61853e4cc73bd593a5",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "9d3540582fb434e36f33b6c65311df42",
"icons/Icon-192.png": "91fe4e6899798f61853e4cc73bd593a5",
"icons/Icon-512.png": "91fe4e6899798f61853e4cc73bd593a5",
"icons/Icon-maskable-192.png": "91fe4e6899798f61853e4cc73bd593a5",
"icons/Icon-maskable-512.png": "91fe4e6899798f61853e4cc73bd593a5",
"index.html": "d5ebaeddb2379ad46fb0a43eac4be02d",
"/": "d5ebaeddb2379ad46fb0a43eac4be02d",
"main.dart.js": "2d5749bfd4c00acfd544b88aa67b4ae4",
"manifest.json": "aa4154e3e4c0eef43d0eea7cbe7db809",
"version.json": "7b514010137ee00de2789bd96d23c634",
"_redirects": "7160d5304a2858665c1cd1b6e5c52215"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

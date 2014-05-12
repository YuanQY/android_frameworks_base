[33mcommit ae4ac7ba976d4abbce8507774d5a5ccc771aaf07[m
Author: Jens Gulin <jens.gulin@sonymobile.com>
Date:   Tue Feb 4 17:38:02 2014 +0100

    Solve three memory leaks related to PatchCache
    
    A Patch can be fairly large, holding bitmap data, but
    is also frequently leaked which adds to the severity.
    The feature is used in many important processes such
    as Home, SystemUI and Chrome.
    
    The following leaks are solved:
    
    1. The Patch itself was not always freed.
    PatchCache::removeDeferred() can mark patches to be
    cared for by PatchCache::clearGarbage(). But
    mCache.remove() would only destroy the container
    and the pointer, not the Patch object itself.
    
    2. The vertices stored in the Patch at Patch::createMesh()
    would always leak. The empty/default destructor in Patch
    would not properly destroy "vertices" since it's just a
    pointer.
    
    3. A BufferBlock that's added to the mFreeBlocks
    in PatchCache could leak. The leak happened when a
    patch later needed the entire free block, because the
    object was removed from the list but never deleted
    in PatchCache::setupMesh().
    
    Change-Id: I41e60824479230b67426fc546d3dbff294c8891f

[33mcommit 898206a5bdabbe166b5a6cc3698a047e92db8d0e[m
Author: Sangkyu Lee <sk82.lee@lge.com>
Date:   Thu Jan 9 14:11:57 2014 +0900

    Fix graphics corruption caused by HWUI caches
    
    Some caches(PatchCache, TextureCache, PathCache) for HWUI
    uses deferred removal for their cache entries even though
    actual resource objects are immediately freed by
    ResourceCache.
    For this reason, the uniqueness of a resource address in
    the caches is not guaranteed in specific cases.
    (Because malloc() can return the same address when malloc()
    and free() called very frequently.)
    
    So it can be possible the cache have two cache entries for
    two different resources but the same memory address.
    (Of course one of the resources is already freed.)
    It also can be possible mGarbage vector in PatchCache has
    duplicated addresses and this can lead to duplicated free
    blocks in the free block list and graphics corruption.
    (Deferred removal was implmeneted based on an assumption of
    unique resource addresses.)
    
    So this patch makes sure resource objects are freed after
    the resources are removed from the caches to guarantee
    the uniqueness of a resource address and prevent graphics
    corruption.
    
    Change-Id: I040f033a4fc783d2c4bc04b113589657c36fb15b
    Signed-off-by: Sangkyu Lee <sk82.lee@lge.com>
    
    Fix AOSP build - DO NOT MERGE
    
    Change-Id: I42b420c2ce89ce364a2809b28b827964e6923fa1

[33mcommit 1da600b0852c1e75087c7b8a8d9ec012101824a1[m
Author: Alexander Toresson <alexander.toresson@sonymobile.com>
Date:   Wed Aug 28 16:13:06 2013 +0200

    Fix for positioning of glyphs within a bitmap
    
    For positioning of glyphs within a bitmap, roundf(int + float) is used,
    where the float is the glyph position and the int is the text position.
    When the text position is varied, this may lead to the sum being rounded
    in different directions, due to floating point rounding, caused by that
    floating point numbers have different precision in different ranges.
    
    This may therefore lead to slightly different positioning for glyphs and
    therefore slightly different widths and heights for text strings,
    depending on the position they are rendered at.
    
    The solution in this patch is to use int + (int) roundf(float), which
    has consistent rounding, and also enables us to use the full range of
    ints.
    
    Change-Id: Id1143cdfcbdfa9915ced878ae04df589a3e03cee

[33mcommit 12b8941ab5fcf8413f2ddff50c6be8ed5724aad9[m
Author: ywen <ywen@codeaurora.org>
Date:   Thu Jan 23 11:26:27 2014 +0800

    Revert "Fix stencil buffer bug."
    
    This reverts commit ea327b48b495168872c1c758c7c744890496650f.
    
    Change-Id: I8e4b8b4c6cf48930907cdb52c95135dd6f338af2

[33mcommit a7e07d2ab6953ea616f52faf92843a1d70febf20[m
Author: lina.x.pi <lina.x.pi@sonymobile.com>
Date:   Thu Jan 9 18:17:03 2014 +0800

    Initialize pointer members to NULL to avoid illegal reference
    
    mBitmap and mTexture is not initialized to NULL which causes
    illegal address access when it fails to be created from
    oversized bitmap.
    Cherry-picked from AOSP: https://android-review.googlesource.com/#/c/79320/
    
    Change-Id: Iea54bec8788bc5f3a10040fdb43f416c0d41a14c

[33mcommit aa25e2b04f1eee5130b08618e983576c3f4c4c5b[m
Author: Ricardo Cerqueira <cyanogenmod@cerqueira.org>
Date:   Mon Dec 2 00:41:58 2013 +0000

    hwui: Apply hwui qcom fixes to all adreno-bearing hardware
    
    Even if the device doesn't fully use the qcom stack, changes to
    libhwui are generally workarounds for adreno-specific issues and
    apply across the board without other dependencies
    
    Change-Id: I10455ebf09c1d00762b06e3c092398604bb39796

[33mcommit 525c2c35a8739c8cf026e38c73cd8e229d8748d0[m
Author: ywen <ywen@codeaurora.org>
Date:   Tue Sep 24 16:46:40 2013 +0800

    Fix stencil buffer bug.
    
    Stencil test is enabled by setStencilFromClip(), but not disabled
    in some use case, which causes some of the pixels are discarded by
    mistake in draws followed. Disable stencil test when there is no
    dirty clip.
    
    CRs-Fixed: 539456
    
    Change-Id: I318fb47212e49e2da89bcbfd161a1689ef91b02f

[33mcommit 67a46b2fe56cdfc65a67f47fc4634a1e2a0cdaf2[m
Author: William McVicker <wmcvicke@codeaurora.org>
Date:   Thu Oct 31 10:42:32 2013 -0700

    Update the layer's alpha value upon composition of the layer
    
    Fixes: This patch makes sure that the layer's alpha value is
    up-to-date and does not reflect the previous view's alpha value.
    It fixes the square block on marquee fading edge when text view
    is applied transparency.
    
    CRs-Fixed: 562000
    
    Change-Id: I397308b739f5f4fe4b630cf594825f401c97e0e3

[33mcommit b4cfbb3c993f5352f2bf6612a092c36b61825efb[m
Author: Rama Vaddula <rvaddula@codeaurora.org>
Date:   Wed Sep 25 15:55:25 2013 -0700

    Remove opaque check in preparing dirty region
    
    Since preserve swap is enabled, we need to clear the color buffer
    when the scissor rect is prepared for a new process. This prevents
    garbage being present from the previous process in the color buffer.
    
    CRs-Fixed: 549755
    
    Change-Id: Icd12ae388077b8c9ed329c37314e896500078543
    (cherry picked from commit 48b6a9767317e08a24e189c9cbee21043543682a)
    (cherry picked from commit 777610a5ddf19cebcad30b7e9a481e9dfe38b74c)

[33mcommit 17ce7ad8d4d0401ab90e268e56ed945c43389847[m
Author: XpLoDWilD <xplodwild@cyanogenmod.org>
Date:   Sun Jul 28 15:48:15 2013 +0200

    hwui: Don't discard framebuffer on exynos4
    
    The layers gets empty/not cleaned and redrawn on top of the preview,
    causing beautiful glitch on homescreen, and drawing black instead
    of transparency.
    
    Change-Id: I633b104224c73c625f1193ee3dde41823cddc5bf

[33mcommit 318ae7bb92869d99a05388c598ad105e7aa4cdbd[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Sep 24 18:44:54 2013 -0700

    Take SkBitmap's stride into account when uploading textures
    Bug #10151807
    
    Change-Id: I7ba4804fa3619088fea70eb55f10519fff0bf5f0

[33mcommit d8a84a8609951826135a2e41a1cdd6b7cf680e27[m
Merge: 7c1b108 996fe65
Author: Chris Craik <ccraik@google.com>
Date:   Sat Sep 21 00:33:36 2013 +0000

    Merge "Correct bitmap merging logic" into klp-dev

[33mcommit 996fe656340ede058a6f0e6b18f9ec525ddb4e27[m
Author: Chris Craik <ccraik@google.com>
Date:   Fri Sep 20 17:13:18 2013 -0700

    Correct bitmap merging logic
    
    bug:10863163
    
    This fixes two issues
    
    The check for pure translation was incorrect. It was fixed and renamed
    for clarity.
    
    Certain matrix paths weren't setting kTypePositiveScale. For
    simplicity (and because positive scale is simple to check) removed
    flag in favor of dynamic checking.
    
    Change-Id: Ic5ce235653ef49a68b8b242bd89fc2e95874ecc9

[33mcommit 16c84069a4cc0c0d3c35e798dc5e4b0130d4a26f[m
Author: Victoria Lease <violets@google.com>
Date:   Thu Sep 19 15:38:21 2013 -0700

    fix emoji clipping in hw draw path
    
    I guess we don't want to overwrite the last line in every RGBA glyph
    with our one-line texture atlas spacer?
    
    Bug: 10841207
    Change-Id: Ief85ca58650c731e9d21dbf90942b7b44670abcc

[33mcommit ce9ee16d654a42f31d211c60708d7b23f17c1d8e[m
Merge: a42ceb0 32f05e3
Author: Chris Craik <ccraik@google.com>
Date:   Wed Sep 18 01:50:02 2013 +0000

    Merge "Conservatively estimate geometry bounds" into klp-dev

[33mcommit a42ceb03cf6a1cbcd9f526afb02d806b2c200ee3[m
Merge: 9b64598 d965bc5
Author: Chris Craik <ccraik@google.com>
Date:   Wed Sep 18 01:49:32 2013 +0000

    Merge "Disallow negative scale matrices in merged Bitmap drawing" into klp-dev

[33mcommit 32f05e343c5ffb17f3235942bcda651bd3b9f1d6[m
Author: Chris Craik <ccraik@google.com>
Date:   Tue Sep 17 16:20:29 2013 -0700

    Conservatively estimate geometry bounds
    
    bug:10761696
    
    Avoids a case where a rect with top coordinate of (e.g.) 0.51f is
    assumed to not draw in the first row of pixels, which leads to it not
    being clipped. Since rounding can cause it to render in this first
    pixel anyway, we very slightly expand geometry bounds.
    
    Now, in ambiguous cases, the geometry bounds are expanded so clipping
    is more likely to happen.
    
    Change-Id: I119b7c7720de07bac1634549724ffb63935567fc

[33mcommit d965bc5823d878a3fd056b8a95fb4eb578ed3fe4[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Sep 16 14:47:13 2013 -0700

    Disallow negative scale matrices in merged Bitmap drawing
    
    bug:10622962
    
    Change-Id: I55ac18ad56b53dc9e6e6ea14cd3ec4bdafa98ac3

[33mcommit 5af5fc50c2f43fc0e0813e02cb6a950901a9c0b8[m
Author: Chris Craik <ccraik@google.com>
Date:   Fri Sep 13 14:41:31 2013 -0700

    Fix merged operation clipping
    
    bug:10745870
    
    Missing 'const' meant MergingDrawBatch would never clip anything.
    
    Change-Id: Ia6367eff94cf5f437efafbc3ba7f0da102ffd956

[33mcommit 1de466fc91511de8428affcf1eb71dc6af946145[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Sep 12 16:09:19 2013 -0700

    Always disable the clip for layers
    Bug #8149344
    
    Change-Id: Ifd413cadb171232eb846b3d91b05b2d2457b9f35

[33mcommit 88ee0dac81dec12aefdeee23072df9b3864a06a4[m
Merge: 2626766 c1c5f08
Author: Chris Craik <ccraik@google.com>
Date:   Thu Sep 12 22:08:54 2013 +0000

    Merge "Move DeferredDisplayState out of ops" into klp-dev

[33mcommit c1c5f0870282b56dafe5a4d756e4b9e6884655a7[m
Author: Chris Craik <ccraik@google.com>
Date:   Wed Sep 11 16:23:37 2013 -0700

    Move DeferredDisplayState out of ops
    
    bug:9969358
    
    Instead of storing DeferredDisplayState within an op (thus forcing ops
    to be tied to a single state instance), associate each op with a new
    state at DeferredDisplayList insertion time.
    
    Now, DisplayLists (and the ops within) can be reused in a single
    DeferredDisplayList draw call, as ops will use different state
    instances at different points in the frame.
    
    Change-Id: I525ab2abe0c3883679f2fa00b219b293e9ec53d9

[33mcommit 874ae2adf8c24c4b9d68f781239a95ad047e212a[m
Merge: 895a437 25d2f7b
Author: John Reck <jreck@google.com>
Date:   Tue Sep 10 21:03:48 2013 +0000

    Merge "Fix scissor for functor invocation" into klp-dev

[33mcommit 7a454ba5fee0bbb9f2e1292f8eede655516c0f2c[m
Author: Tim Murray <timmurray@google.com>
Date:   Tue Sep 10 13:46:49 2013 -0700

    Fix FontRenderer bug.
    
    bug 10691313
    
    Change-Id: Icd5341a3c2066e337911f040ddc935c48c8d7cd1

[33mcommit 25d2f7bc1ff9b475eff75bfff647466e91dbacb2[m
Author: John Reck <jreck@google.com>
Date:   Tue Sep 10 13:12:09 2013 -0700

    Fix scissor for functor invocation
    
     Bug: 10677765
     enableScissor() must precede setScissorFromClip() as
     otherwise setScissorFromClip() doesn't do anything.
     Also make sure to call setScissorFromClip() if
     enableScissor() returns true as enableScissor() calls
     resetScissor() if the scissor state has changed.
    
    Change-Id: I9226b20bb256c92066aae344e4e6407540b6eae9

[33mcommit 9578e642403c0fa4fdcb32828f27c2417cabe88d[m
Author: Tim Murray <timmurray@google.com>
Date:   Mon Sep 9 16:15:56 2013 -0700

    Add flags word to initialization.
    
    bug 10427951
    
    Change-Id: I1356b9b96315ead44aa3898de5604d75f9bb8be5

[33mcommit 66063ae2d6ff523bbf200cccdb9223d824c240a4[m
Author: Chris Craik <ccraik@google.com>
Date:   Thu Sep 5 16:11:18 2013 -0700

    Dump the right matrix when logging display lists
    
    bug:10631274
    Change-Id: I6b32bfcb3e207321da60807091d7ac0ecf6112ab

[33mcommit 54f574acf4dd5483170b8f79e2f7c70b58763ce7[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Aug 26 11:23:46 2013 -0700

    Move functor GL setup to just before functor
    
    bug:10399469
    
    Because the stencil setup can issue draws, it *must* come before the
    GL state setup.
    
    Change-Id: I52a36213549fc60b091a90cbb923a1f0d35f9a65

[33mcommit 5d923200846ed59e813373bde789d97d4ccc40b5[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Aug 21 18:40:24 2013 -0700

    Second attempt at avoiding infinite loop in PathCache::trim()
    Bug #10347089
    
    Change-Id: I70f5a3933e848632473acc6636c88be5dc6ac430

[33mcommit 0a8c51b1d0d66d6060afcec1eab33091d49332ae[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Aug 21 17:35:38 2013 -0700

    Properly account for created paths in the cache
    
    Change-Id: I47b89b3085cefab6daac9194e7bfd3c140b37fa2

[33mcommit 627c6fd91377ead85f74a365438e25610ef1e2ee[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Aug 21 11:53:18 2013 -0700

    Add overdraw debugging that accounts for Deuteranomaly
    
    Change-Id: I31f68a07aa7cf0490d2572e24e4c5ac2066a1151

[33mcommit d8c8aaa82ef90f30df647ca42453e953ee52af0f[m
Author: Tim Murray <timmurray@google.com>
Date:   Mon Aug 19 12:04:38 2013 -0700

    Handle updates to C++ API.
    
    Change-Id: I8ab17cbae3a9a4cc3c3202b8277d49f27bdf1fec

[33mcommit 46bfc4811094e5b1e3196246e457d4c6b58332ec[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Aug 16 18:38:29 2013 -0700

    Fix hardware layers lifecycle
    Bug #10075732
    
    Hardware layers could survive across EGL terminate events.
    
    Change-Id: Ie8565d55cb29fe6625fa1584d695edfecd37ab5e

[33mcommit b0a41ed3dcc34a2b4026f6cc8336796f3523aa21[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Aug 16 14:44:38 2013 -0700

    Prevent ANR in apps using drawPath()
    Bug #10347089
    
    If an app clears its path cache before stopping background tasks, it could
    get into an infinite loop in PathCache::trim().
    
    Change-Id: Ieb865b762e7b00aebaba0c023769c2db286a94f5

[33mcommit b746371de7f21ae36a14953d9b253df06838efb1[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Aug 16 13:55:29 2013 -0700

    Clear FBO cache on full memory flush
    
    Change-Id: I44e06d5d15cd899a0522c62d7c0d042170665abb

[33mcommit 723b2feb929b96b1dde40a865c49ea18bc42f055[m
Author: Victoria Lease <violets@google.com>
Date:   Mon Aug 12 14:38:44 2013 -0700

    fix kBW_Format glyphs
    
    Oops! kBW_Format was omitted from a couple of switch statements,
    resulting in glyphs in that format being invisible.
    
    Bug: 10206452
    Change-Id: Ib2aa52250aeeecc0de1b1b78e3d0f568f368c73e

[33mcommit 9b5a1a28c327e6113d68302b1f0eed1d1c6f6183[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Aug 9 14:06:29 2013 -0700

    Take shadow bounds into account for quick rejects
    Bug #8634346
    
    Change-Id: I995c5205c2959d8e4da638ae47fedcda92eb1b36

[33mcommit 003123004f7b23b3dc472d5c40b8c1a16df37a54[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Aug 8 19:11:20 2013 -0700

    Remove an unnecessary allocation
    
    Also remove dead code from OpenGLRenderer.cpp
    
    Change-Id: I7eb54ca19e77ee3c32f1fe9513a031e6b2e115cf
    (cherry picked from commit 5c7d5ab878b26f855175a3305a14ac12fcacf25e)

[33mcommit 7f6d6b0370df4b5a9e0f45bffc31ea6caeeb509d[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Aug 6 13:49:28 2013 -0700

    Split assets atlas batches
    Bug #10185769
    
    The assets atlas contains assets that need to be blended and assets
    that do not need to be blended. With a single merge id, currently
    set to be the pointer to the atlas itself, draw ops merging could
    generate batches of commands containing both opaque and translucent
    assets. The blend state was chosen from only one of the assets in
    the batch, leading either to inefficiencies (blending large opaque
    assets) or incorrect behaviors (not blending translucent assets.)
    
    This change introduces two new merge ids in the atlas: an opaque
    key and a blend key. These keys are simple booleans set to false
    and true respectively (the values do not matter really.) Their
    memory addresses are used as the merge ids when createing draw ops
    batches, allowing all opaque ops to be batched together and all
    translucent ops to be batched together.
    
    Change-Id: I114dba0533c44987e53864b471ccb28c811f2025

[33mcommit 250b1cfc831fd2a271c09cab547efcc5e3d5f828[m
Author: Tim Murray <timmurray@google.com>
Date:   Thu Aug 1 14:49:22 2013 -0700

    Handle updates to RS C++ API.
    
    Change-Id: I73127fc7369643b94d4a49f31a516b50c74b54ac

[33mcommit b213cec0ce659c1e35c3e7f60a61bae38d94482a[m
Merge: 03ed012 5e49b30
Author: Chris Craik <ccraik@google.com>
Date:   Fri Aug 2 20:34:38 2013 +0000

    Merge "Fix quickReject's handling of AA ramp geometry"

[33mcommit 5e49b307eb99269db2db257760508b8efd7bb97d[m
Author: Chris Craik <ccraik@google.com>
Date:   Tue Jul 30 19:05:20 2013 -0700

    Fix quickReject's handling of AA ramp geometry
    
    By having quickReject round out the window-space geometry bounds, we
    prevent the AA perimeter (which falls outside the local bounds passed
    in) from drawing outside the clip.
    
    Change-Id: I8ee36be9039a9c47906815ee2f0dbaa5eb910b82

[33mcommit b7b93e00893f5c690a96bd3e0e10583bc5721f83[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Aug 1 15:29:25 2013 -0700

    Fix region clipping bugs
    See external bug #58344
    
    Change-Id: Iecd6c41fc8076cd76add2335d3442a6dd8878f12

[33mcommit 1e546815bbb736c50679a8aefc25f48561026fc5[m
Author: Victoria Lease <violets@google.com>
Date:   Tue Jun 25 14:25:17 2013 -0700

    Support RGBA fonts and bitmap fonts (and RGBA bitmap fonts)
    
    Quite a few things going on in this commit:
    
    - Enable bitmap strikes by default in Paint objects.
    
    The SkPaint parameter that enables bitmap strikes was not previously
    included in DEFAULT_PAINT_FLAGS. This effectively disabled bitmap
    fonts. Oops! It's for the best, though, as additional work was needed
    in Skia to make bitmap fonts work anyway.
    
    - Complain if TEXTURE_BORDER_SIZE is not 1.
    
    Our glyph cache code does not currently handle any value other than 1
    here, including zero. I've added a little C preprocessor check to
    prevent future engineers (including especially future-me) from
    thinking that they can change this value without updating the related
    code.
    
    - Add GL_RGBA support to hwui's FontRenderer and friends
    
    This also happened to involve some refactoring for convenience and
    cleanliness.
    
    Bug: 9577689
    Change-Id: I0abd1e5a0d6623106247fb6421787e2c2f2ea19c

[33mcommit fb6c743c6e01aa2d4c457d85389a698a193c60b8[m
Merge: 87c79a1 6cad757
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jul 24 18:54:11 2013 +0000

    Merge "Fix 9patches' limitation of 32 empty quads"

[33mcommit 6cad75744ed3b81cf2c96f545368067b62c726ec[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jul 24 11:49:33 2013 -0700

    Fix 9patches' limitation of 32 empty quads
    
    The 9patch format allows to define more empty quads than this, remove
    the use of a single int to index empty quads and replace it with a
    lookup in the 9patch resource data structure.
    
    Change-Id: I148ee5d9e0c96822b534a344e15c9d88078db7c2

[33mcommit 98427708a81eefcc24ae29e2f22e55f1ae44c927[m
Merge: fd23eca 9ab2d18
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jul 22 23:31:18 2013 +0000

    Merge "Ensure glActiveTexture is cleaned up correctly on functor resume"

[33mcommit 9ab2d1847552aa4169b4325aae1b1368d6947a9f[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jul 22 16:16:06 2013 -0700

    Ensure glActiveTexture is cleaned up correctly on functor resume
    
    Change-Id: I103d7d63b17289d599c2c08dcc442cfba9b8e51d

[33mcommit 448455fe783b0a711340322dca272b8cc0ebe473[m
Author: Romain Guy <romainguy@google.com>
Date:   Mon Jul 22 13:57:50 2013 -0700

    Use global indices array to draw layers
    
    An array of indices local to a layer would only be necessary if
    we changed the way we resolve T-junctions. Since we only ever
    draw quads, let's just use the indices we use everywhere else.
    
    This change also uses the global indices array to render list
    of colored rectangles to save on the number of vertices generated
    CPU-side.
    
    Change-Id: Ia6d1970b0e9247805af5a114ca2a84b5d0b7c282

[33mcommit b3d83888229d9a9d40c3ada037fcf6f96e80e125[m
Merge: 07c09ce ecca6da
Author: Chris Craik <ccraik@google.com>
Date:   Tue Jul 16 22:43:01 2013 +0000

    Merge "Support stencil-based clipping for functors"

[33mcommit 4e7b772b733593fbe25c733e95b8dcea293234b6[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Jul 16 13:47:01 2013 -0700

    Fix crashes in setMatrix() and concat()
    
    setMatrix() was crashing in native code, only with hw acceleration on.
    concat() would throw a NullPointerException. It now ignores null matrices.
    
    Change-Id: Iebd8b410a957d2ba501570c6fbb3f680ff4a1a23

[33mcommit ecca6da4eab601f05a9d977c8d2651068b6e16b2[m
Author: Chris Craik <ccraik@google.com>
Date:   Tue Jul 16 13:27:18 2013 -0700

    Support stencil-based clipping for functors
    
    bug:9070351
    Change-Id: I1c54e1bea1b84b1619cce27b14f189b42cab7062

[33mcommit 0c20c3898a533b7b76f60827cb6ea02e17c5953d[m
Author: Chris Craik <ccraik@google.com>
Date:   Tue Jul 2 10:48:54 2013 -0700

    Use global references for Bitmap AndroidPixelRefs
    
    bug:9621717
    
    Because we're no longer holding onto Bitmaps Java side during
    DisplayList lifetime, use global refs to keep the backing byte arrays
    around.
    
    Adds back bitmap buffer passing + native ref management removed by
    3b748a44c6bd2ea05fe16839caf73dbe50bd7ae9
    
    Adds back globalRef-ing removed by
    f890fab5a6715548e520a6f010a3bfe7607ce56e
    
    Change-Id: Ia59ba42f05bea6165aec2b800619221a8083d580

[33mcommit c36fe2fc5354fadc140c898f59d47859cbdeac67[m
Merge: 1e09cfa 55e789d
Author: Romain Guy <romainguy@google.com>
Date:   Fri Jun 28 11:15:02 2013 -0700

    am 55e789db: am ed96349a: am 3d1b158e: Merge "Fix out of range glCopyTexImage2D Bug #9425270" into jb-mr2-dev
    
    * commit '55e789dbc782be0dcaf1d4bae5f32e9e2f674152':
      Fix out of range glCopyTexImage2D Bug #9425270

[33mcommit b254c242d98f4a9d98055726446351e52bece2c6[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 27 17:15:24 2013 -0700

    Fix out of range glCopyTexImage2D
    Bug #9425270
    
    A better solution would be to use glCopyTexImage2D whenever possible but
    this change would be a little more dangerous.
    
    Change-Id: Ib1aaceda39d838716285ef97f356721416822dbb

[33mcommit 55b6f95ee4ace96c97508bcd14483fb4e9dbeaa0[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 27 15:27:09 2013 -0700

    Track the atlas' generation ID
    Bug #9589379
    
    If the atlas is terminated/reinitialized and a view does not invalidate
    in between it might end up using a stale AssetAtlas::Entry. This change
    is similar to how 9patch meshes are cached in DrawPatchOp: we simply
    track the generation ID of the cache to make sure we always use the
    latest data.
    
    Change-Id: Ib5abb3769d2ce0eabe9adc04e320ca27c422019e

[33mcommit e3b0a0117a2ab4118f868a731b238fe8f2430276[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 26 15:45:41 2013 -0700

    Refcount 9-patches and properly handle GC events
    
    This change adds refcounting of Res_png_9patch instances, the native
    data structure used to represent 9-patches. The Dalvik NinePatch class
    now holds a native pointer instead of a Dalvik byte[]. This pointer
    is used whenever we need to draw the 9-patch (software or hardware.)
    
    Since we are now tracking garbage collection of NinePatch objects
    libhwui's PatchCache must keep a list of free blocks in the VBO
    used to store the meshes.
    
    This change also removes unnecessary instances tracking from
    GLES20DisplayList. Bitmaps and 9-patches are refcounted at the
    native level and do not need to be tracked by the Dalvik layer.
    
    Change-Id: Ib8682d573a538aaf1945f8ec5a9bd5da5d16f74b

[33mcommit f296dca95f09be9832b5dcc79717986525d2b6cb[m
Author: Romain Guy <romainguy@google.com>
Date:   Mon Jun 24 14:33:37 2013 -0700

    (Small) 9patch drawing improvements
    
    Save a bit of memory in meshs generated from native code
    Avoid an extra if/else when drawing with hardware accelration on
    
    Change-Id: I31a4550bde4d2c27961710ebcc92b66cd71153cc

[33mcommit 4f20f8ae50ecc3b6c04afd2e62716ca87620962b[m
Merge: b06accf 0e87f00
Author: Chris Craik <ccraik@google.com>
Date:   Fri Jun 21 20:51:54 2013 +0000

    Merge "Initialize MergingDrawBatch clip with viewport bounds"

[33mcommit 0e87f00f8cb79635aa70b9a2dfa02bf19dc7473d[m
Author: Chris Craik <ccraik@google.com>
Date:   Wed Jun 19 16:54:59 2013 -0700

    Initialize MergingDrawBatch clip with viewport bounds
    
    This allows merged, clipped operations to behave correctly within a
    savelayer, even if the base viewport has a large offset.
    
    Additionally, disregard opaqueness when within a
    complexclip/savelayer, as the coverage can't be trusted.
    
    Change-Id: Ic908b82a4bb410bc7fac1b4295f4874ed166efc5

[33mcommit 64d592129e4f5231f61ac2b6055e1b37f8c0ebb6[m
Merge: b38d53d 16ea8d3
Author: Romain Guy <romainguy@google.com>
Date:   Fri Jun 21 18:37:56 2013 +0000

    Merge "Refcount the paint used by Canvas.drawPatch()"

[33mcommit 16ea8d373b03b1e115dd505af70dbee4e3a3a182[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Jun 21 11:35:52 2013 -0700

    Refcount the paint used by Canvas.drawPatch()
    
    Prevents crashes :)
    
    Change-Id: I62103ce97490613142321f080b82c2edaed67a95

[33mcommit 2c290392c9a934f9ac48364af01c848b01ba8e80[m
Merge: ede7eb7 03c00b5
Author: Romain Guy <romainguy@google.com>
Date:   Fri Jun 21 17:42:23 2013 +0000

    Merge "Batch 9-patches in a single mesh whenever possible"

[33mcommit ede7eb7749e08b6343955cf52304a17f21c54e6f[m
Merge: 3b8b276 c5493fb
Author: Chris Craik <ccraik@google.com>
Date:   Fri Jun 21 17:39:14 2013 +0000

    Merge "Make op outputting const, for more general logging"

[33mcommit 03c00b5a135e68d22ca5bb829b899ebda6ed7e9d[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 20 18:30:28 2013 -0700

    Batch 9-patches in a single mesh whenever possible
    
    This change also fixes the way batched bitmaps were handled
    inside a layer. The layer is now correctly dirtied to minimize
    the amount of pixels to blend.
    
    Fix alpha, mode and opaque computations for DrawPatchOp.
    
    Change-Id: I1b6cd581c0f0db66c1002bb4fb1a9811e55bfa78

[33mcommit d485ef27c795648c4a05c4c089e8c5a15712fd36[m
Merge: fb5dbfe f6bed4f
Author: Romain Guy <romainguy@google.com>
Date:   Fri Jun 21 01:31:54 2013 +0000

    Merge "An identity matrix should be considered a pure translate matrix"

[33mcommit f6bed4f12a2c975678fc0bdea15054ab169aafb5[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 20 17:52:07 2013 -0700

    An identity matrix should be considered a pure translate matrix
    
    Change-Id: I75e91797e8270f902f67bdd7bb526cccc23adc6b

[33mcommit d4fed90d246a8decf962cd3a63507a3637354fb1[m
Merge: 6ebe3de 9e6f3ac
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 20 23:32:39 2013 +0000

    Merge "Add debugging logs for GPU pixel buffers"

[33mcommit 9e6f3ac109b5cd7736122d1bdf83ed38b9d739c6[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 20 16:31:35 2013 -0700

    Add debugging logs for GPU pixel buffers
    
    Change-Id: I7edb04dd30ee6fd823099e72788169cc185e70f2

[33mcommit c5493fb7fa1f6995955c667d4377f2337f2cf465[m
Author: Chris Craik <ccraik@google.com>
Date:   Wed Jun 19 16:58:58 2013 -0700

    Make op outputting const, for more general logging
    
    Change-Id: Iaf78985ee5558e0b5d32d7bc1cd039eaffc820e5

[33mcommit fb5a41a371e540f402e3dd987b0fbf92d1267902[m
Merge: ff4ea79 2458939
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 19 23:40:57 2013 +0000

    Merge "Fix regression: TextureView.setAlpha() was ignored"

[33mcommit 2458939b5f926176a485a3196f59688eed78e858[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 19 12:17:01 2013 -0700

    Fix regression: TextureView.setAlpha() was ignored
    
    Change-Id: I9f43eec0fe23a65dcc1cf9cd0ac1f5e8907786a7

[33mcommit cadc5bf4116945a1800061f984d95175e20caba6[m
Merge: 1f54f92 31e08e9
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 19 19:16:21 2013 +0000

    Merge "Share Caches' index buffer with FontRenderer"

[33mcommit 31e08e953fe7bdb1b1cbc247156cb6a19917a2f1[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Jun 18 15:53:53 2013 -0700

    Share Caches' index buffer with FontRenderer
    
    This reduces state changes when we draw 9patches and text together,
    which happens *a lot*. Also disable the NV profiling extension by
    default since it doesn't play nice with display lists deferrals.
    To enable it set debug.hwui.nv_profiling to true.
    
    Change-Id: I518b44b7d294e5def10c78911ceb9f01ae401609

[33mcommit 77d55c7e5c7ace27dfe56665a59edc17102418a8[m
Merge: ae2db13 2d5945e
Author: Romain Guy <romainguy@google.com>
Date:   Tue Jun 18 20:08:38 2013 +0000

    Merge "Take hinting into account when caching fonts Bug #9464403"

[33mcommit 2d5945e88731787babce1061f44cd54f02eeefc5[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Jun 18 12:59:25 2013 -0700

    Take hinting into account when caching fonts
    Bug #9464403
    
    Change-Id: I26a5f0c17eb27d096717b444d3e18ad1d2b5a43c

[33mcommit 49cc5d71192cbd776e237488218aea18a3ed14b1[m
Merge: 3e0a463 f09b746
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 22:50:39 2013 +0000

    Merge "Handle all text bounds as post-translated"

[33mcommit f09b746acb266a849f3421df1604ebec161bb93d[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 15:17:11 2013 -0700

    Handle all text bounds as post-translated
    
    We were treating immediate mode bounds as pre translate, which is
    inconsistent with using them for quickRejection.
    
    This fixes the overdraw counter not drawing correctly (since it uses
    immediate mode drawing.
    
    Change-Id: I1c734d367a00942bd7d9b041822c0a9f284e70a8

[33mcommit 36d38cb904556025b76c6d98f9fe2ccfa1c8a304[m
Merge: f0542ee d72b73c
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 21:02:56 2013 +0000

    Merge "Better handle op size edge cases"

[33mcommit d72b73cea49f29c41661e55eb6bfdbc04f09d809[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 13:52:06 2013 -0700

    Better handle op size edge cases
    
    bug:9464358
    
    Previously, empty and unknown sized ops are assumed to fully cover
    their clip. This is now corrected such that empty sized ops are
    pre-rejected before defer. Additionally, unknown sized ops disable
    overdraw avoidance.
    
    Change-Id: Icf2ce24f98be5ea6299e24ffcf826790373564a1

[33mcommit fb5c9050978afad2c1df570a13a6747f438c27f7[m
Merge: 61e1ca6 e93482f
Author: Romain Guy <romainguy@google.com>
Date:   Mon Jun 17 20:39:45 2013 +0000

    Merge "Cancel layer update when a layer is about to be destroyed Bug #9310706"

[33mcommit e93482f5eac3df581d57e64c2a771a96aa868585[m
Author: Romain Guy <romainguy@google.com>
Date:   Mon Jun 17 13:14:51 2013 -0700

    Cancel layer update when a layer is about to be destroyed
    Bug #9310706
    
    Change-Id: I73eea6314c326f15a979617e3a05b525935f0d3f

[33mcommit 61e1ca68fa82e5228b5bfcdad8deecd9383fb183[m
Merge: 0a1e961 8c6e17c
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 20:16:37 2013 +0000

    Merge "Check for layer renderer in flush"

[33mcommit 8c6e17c2a9b0ad7864a261cc9a30b9623e20bdcb[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 13:02:12 2013 -0700

    Check for layer renderer in flush
    
    bug:9310706
    
    In some cases flush will occur after a layer is destroyed. Avoid
    trying to draw after putting the layer in the layer cache.
    
    Change-Id: I55d66f420e7354fe552c82eb3145a7d91b4441e3

[33mcommit 2a0451e54a3c3b397861736c42e42125bd938d43[m
Merge: 4aaf8b3 a02c4ed
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 17 18:11:34 2013 +0000

    Merge "Fix clip merging behavior"

[33mcommit 5216c3b05fc6c7bacd74be67b932fe3aba89cc8e[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Jun 14 16:31:37 2013 -0700

    Merge more 9patches
    
    Change-Id: If8b16af84f0ee42afc406922d15897e51d833e68

[33mcommit a02c4ed885d97e516f844ddb0a96083f1b45b4cb[m
Author: Chris Craik <ccraik@google.com>
Date:   Fri Jun 14 13:43:58 2013 -0700

    Fix clip merging behavior
    
    Previously, a new op with a clipped side could be added to a
    MergingDrawBatch without considering the batch's current bounds.
    
    Change-Id: I1b873ecf821bad7cda6630c3f311edd90ac5cc8c

[33mcommit d1f9aaa5d776a94907f9e5b632125648043c47b3[m
Merge: e08d54b 39a908c
Author: Chris Craik <ccraik@google.com>
Date:   Fri Jun 14 01:06:29 2013 +0000

    Merge "Fix various draw ops that may incorrectly not scissor"

[33mcommit 39a908c1df89e1073627b0dcbce922d826b67055[m
Author: Chris Craik <ccraik@google.com>
Date:   Thu Jun 13 14:39:01 2013 -0700

    Fix various draw ops that may incorrectly not scissor
    
    bug:8965976
    
    Also consolidates quickReject scissor-ing and scissor-less paths.
    Renamed plain 'quickReject' method, as it has sideEffects beyond what
    the java and skia canvases do.
    
    Change-Id: I4bdf874d3c8f469d283eae1e71c5e7ea53d47016

[33mcommit 735760e3c28c18a86ba503031497cb2d5fa81903[m
Merge: 539d270 7f43076
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 13 22:10:21 2013 +0000

    Merge "Add new Query class for debugging"

[33mcommit 7f4307668b10467ee39d41c7ea29cf1ff238a835[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 13 14:29:40 2013 -0700

    Add new Query class for debugging
    
    This class can be used to perform occlusion queries. An occlusion query
    can be used to test whether an object is entirely hidden or not.
    
    Change-Id: Ida456df81dbe008a64d3ff4cb7879340785c6abf

[33mcommit f70119cd776f871a82c94be8522dce02e04c73a8[m
Author: Chris Craik <ccraik@google.com>
Date:   Thu Jun 13 11:21:22 2013 -0700

    Reset batching state when overlap batch deletion occurs
    
    Change-Id: Ifdbee9baaa734e27d15d2b54aa3b3abfffbce1e9

[33mcommit 7112fddbe26acb12f478f4e77ff9607b523180b4[m
Merge: 512d8fb 4054360
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 13 01:19:46 2013 +0000

    Merge "Restore buildLayer()'s old behavior; it's synchronous again Bug #9193833"

[33mcommit 149b015db9a478c6345cf0528fe4df3c7c2b5110[m
Merge: af0fa4f 28ce94a
Author: Chris Craik <ccraik@google.com>
Date:   Thu Jun 13 00:37:02 2013 +0000

    Merge "Overdraw avoidance and merging of clipped ops"

[33mcommit 9846de68f1b4f2720da421e5242017c28cfc93ed[m
Author: Chris Craik <ccraik@google.com>
Date:   Wed Jun 12 16:23:00 2013 -0700

    Remove crash workarounds, add logging
    
    bug:9321162
    Change-Id: I748c27f979af1a303be01db29aedcbad6d608c38

[33mcommit 405436021da156fbe3c5d4de48bdefa564cf7fc0[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 12 15:31:28 2013 -0700

    Restore buildLayer()'s old behavior; it's synchronous again
    Bug #9193833
    
    Change-Id: I4ee07e65c0a8967f0b55da030ecaad6dfc46136f

[33mcommit 28ce94a4ffc7576f40776d212f1ada79fafaa061[m
Author: Chris Craik <ccraik@google.com>
Date:   Fri May 31 11:38:03 2013 -0700

    Overdraw avoidance and merging of clipped ops
    
    bug:8951267
    
    If an opaque op, or group of opaque ops covers the invalidate region,
    skip draw operations that precede it.
    
    Clipped operations may now be merged, but only if they share a
    clipRect - this is a very case for e.g. ListView, where all background
    elements may now be a part of the same MergingDrawBatch.
    
    It is this more aggressive merging that groups together clipped
    background elements in the ListView case, enabling the overdraw
    avoidance skipping the window background.
    
    Change-Id: Ib0961977e272c5ac37f59e4c67d828467422d259

[33mcommit 1e4795ab64755bdae48fe7b8cd78f204c9022791[m
Merge: fc74f85 4c2547f
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 12 00:23:27 2013 +0000

    Merge "Avoid 9patch cache lookups when possible"

[33mcommit 4c2547fa9244e78115cde0a259291053108c3dc7[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Jun 11 16:19:24 2013 -0700

    Avoid 9patch cache lookups when possible
    
    This optimization saves up to 0.3ms per frame on the Play Store's
    front page, on a Nexus 4 device.
    
    Change-Id: Iaa4ef33c6e3b37e175efd5b9eea9ef59b43f14f3

[33mcommit e13fb01d25b22f46206115faff2c7787d330f0d1[m
Merge: ffcec1d 8cb26c0
Author: Chris Craik <ccraik@google.com>
Date:   Tue Jun 11 14:13:32 2013 -0700

    am 8cb26c09: am cb5d644f: Merge "Workaround possible use after delete" into jb-mr2-dev
    
    * commit '8cb26c099dc6357340141c9d81a1131ee404ae41':
      Workaround possible use after delete

[33mcommit 9abddd54d4177d1a9790889046407da13aa7077b[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Jun 10 11:28:51 2013 -0700

    Workaround possible use after delete
    
    bug:9321162
    Change-Id: Ic35af5b5925da56e9a143e6b33658831038f3b72

[33mcommit be1b127c7bec252e0c6ab0e06ed6babed07d496f[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu Jun 6 14:02:54 2013 -0700

    Assume a texture is unbound after deleting it
    Bug #9316260
    
    The GL specification indicates that deleting a bound texture has
    the side effect of binding the default texture (name=0). This change
    replaces all calls to glDeleteTextures() by Caches::deleteTexture()
    to properly keep track of texture bindings.
    
    Change-Id: Ifbc60ef433e0f9776a668dd5bd5f0adbc65a77a0

[33mcommit 450dc7554de90026a6dd2a1ec7108c1423fce18e[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Jun 5 14:14:03 2013 -0700

    Remove string allocations when creating display lists
    
    Change-Id: Id520db981a3988cb980c8da5dbea8f26ef94989f

[33mcommit 8aa195d7081b889f3a7b1f426cbd8556377aae5e[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Jun 4 18:00:09 2013 -0700

    Introduce Caches::bindTexture() to reduce glBindTexture calls
    
    Change-Id: Ic345422567c020c0a9035ff51dcf2ae2a1fc59f4

[33mcommit f9f0016b1ff816eb2c7561eed482c056189005f8[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu May 9 11:50:12 2013 -0700

    Enable GPU pixel buffers on OpenGL ES 3.0 devices
    
    Change-Id: I164d72ccd7a9bf6ae0e3f79dfef50083558937ba

[33mcommit 7d9b1b3c02eb1ffd99742ecb7b69e3ab97d2ba18[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue May 28 14:25:09 2013 -0700

    Re-initialize the 9patch cache if cleared with onTrimMemory
    
    The 9aptch cache was reinitialized after destroying/recreating
    the EGL context but not after clearing it during a normal
    memory trim.
    
    Change-Id: If6155bfc8a62439e9878bc742a4766b3bd6c6aec

[33mcommit a404e16e4933857464046d763ed7629cd0c86cbf[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri May 24 16:19:19 2013 -0700

    Make sure atlas antries can correctly filter/wrap textures
    
    The virtual textures would each have their own values for wrapping
    and filtering which could lead to conflict and/or extraneous GL
    commands being issued.
    
    Change-Id: I64cb59a03e598f46bf645bd1d30fccfa63a07431

[33mcommit 608094041177193dcce7a91e8dc96a2556d29bfd[m
Merge: ac5b347 e9bc11f
Author: Romain Guy <romainguy@google.com>
Date:   Thu May 23 19:50:58 2013 +0000

    Merge "Add PerfHUD ES profiling capabilities"

[33mcommit e9bc11f7121dbe373b0cbe5779ee6a12d824492c[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu May 23 12:47:26 2013 -0700

    Add PerfHUD ES profiling capabilities
    
    The eglGetSystemTimeNV extension can be used to enable profiling
    in PerfHUD ES. When the delta of two calls to eglGetSystemTimeNV
    equals 0, we now cancels display lists updates. This allows the
    tool to redraw the same frame several times in a row to run its
    analysis.
    
    For better results profiling should only be attempted after
    setting viewroot.profile_rendering to true using adb shell
    setprop.
    
    Change-Id: I02e3c237418004cff8d6cb0b9a37126efae44c90

[33mcommit 341ac60009e6b3c1114938f40743fd81a0ce034f[m
Merge: 664ed99 1bf58a5
Author: Chet Haase <chet@google.com>
Date:   Thu May 23 11:28:05 2013 -0700

    am 1bf58a5a: am cfbbc864: Merge "Restore previous alpha value on noop\'d DisplayList operations" into jb-mr2-dev
    
    * commit '1bf58a5a4c3275a8de676046da311ec0c3c61c78':
      Restore previous alpha value on noop'd DisplayList operations

[33mcommit c725903eec82aa73ebe9682d142904c06321bc2c[m
Author: Chet Haase <chet@google.com>
Date:   Thu May 23 07:57:17 2013 -0700

    Restore previous alpha value on noop'd DisplayList operations
    
    Previously, when a DisplayList operation was rejected because it was not
    in the clip bounds, the code would not properly restore the previous
    state, leading to errors in alpha values of the noop'd op being applied
    to unrelated operations later in the DisplayList.
    
    Issue #9051935 Flash of grey background when transitioning to conversation view
    
    Change-Id: I56645cc9ebf2e07be0228ca5e249213dbeb10d7d

[33mcommit 7f77736599c39cdd5540168fc652cf6846799a33[m
Merge: 4154182 2db5e99
Author: Romain Guy <romainguy@google.com>
Date:   Wed May 22 00:43:48 2013 +0000

    Merge "Merge scaled bitmaps with translated bitmaps"

[33mcommit 2db5e993b626794eb07a0ff354269f9a77da81b3[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue May 21 15:29:59 2013 -0700

    Merge scaled bitmaps with translated bitmaps
    
    Change-Id: I03089f48f97b69fcb4a0171984d3ff548d41c4a8

[33mcommit 41541825bc90dac740e424cdd41a8c997e15cdb7[m
Author: Chris Craik <ccraik@google.com>
Date:   Fri May 3 16:35:54 2013 -0700

    Use individual glyph positions to determine text bounds.
    
    bug:8766924
    
    Previously text bounds were calculated to be from 0 to totalAdvance in
    the X, and from the font's top to bottom. These are incorrect,
    especially in light of the font fallback mechanism.
    
    Now, we calculate the bounds of the text as we layout each glyph.
    Since these are much tighter bounds in the common case, this
    significantly reduces the amount of clipping required (which in turn
    enables more aggressive text merging).
    
    Change-Id: I172e5466bf5975bf837af894a9964c41db538746

[33mcommit 7f43674db314ab76e77cfd2a9488058eae144aa8[m
Merge: a66c789 6045d2b
Author: Chris Craik <ccraik@google.com>
Date:   Tue May 21 20:30:19 2013 +0000

    Merge "Fix DISPLAY_LIST_DEBUG"

[33mcommit 6045d2b7cd0fe62d4385a053bbd1a74d64614d8e[m
Author: Chris Craik <ccraik@google.com>
Date:   Tue May 21 10:49:47 2013 -0700

    Fix DISPLAY_LIST_DEBUG
    
    will now log ops
    
    Change-Id: I4e119999af7ceea0558225aa78926e761277fee2

[33mcommit 6d29c8d5218cac0fb35f3b7c253f2bdebd44f15a[m
Author: Chris Craik <ccraik@google.com>
Date:   Wed May 8 18:35:44 2013 -0700

    Add tessellation path for points
    
    bug:4351353
    bug:8185479
    
    Point tessellation is similar to line special case, except that we
    only tessellate one point (as a circle or rect) and duplicate it
    across other instances.
    
    Additionally:
    
    Fixes square caps for AA=false lines
    
    Cleanup in CanvasCompare, disabling interpolation on zoomed-in
    comparison view
    
    Change-Id: I0756fcc4b20f77878fed0d8057297c80e82ed9dc

[33mcommit e8f9a37395691f8988e09c8efb9ab1601025c5dc[m
Merge: 2b8ae6f f420a36
Author: Chris Craik <ccraik@google.com>
Date:   Fri May 10 12:46:45 2013 -0700

    am f420a36e: am 4329ee25: Merge "Fix off by one error in log tracking" into jb-mr2-dev
    
    * commit 'f420a36e5f62a9ab38f6782db78f5d94947b034e':
      Fix off by one error in log tracking

[33mcommit d4b43b3cf3ee109a5251228dcc1d9bc3c25ff150[m
Author: Chris Craik <ccraik@google.com>
Date:   Thu May 9 13:07:52 2013 -0700

    Fix off by one error in log tracking
    
    bug:8875715
    
    Additionally moves op logging before the op is executed, to print
    correctly, in pre-order traversal
    
    Change-Id: I4e9566261f8363c73739d183e6d82b854f72ffad

[33mcommit 1f5762e646bed2290934280464832782766ee68e[m
Author: Mathias Agopian <mathias@google.com>
Date:   Mon May 6 20:20:34 2013 -0700

    libutils clean-up
    
    Change-Id: I11ee943da23a66828455a9770fc3c5ceb4bbcaa9

[33mcommit d5207b2eb9ba520da822d61ff78b539842fc5255[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue May 7 14:46:36 2013 -0700

    Fix double-free in AssetAtlas
    Bug #8833153
    
    If Atlas::terminate() is called twice without an init() in between
    libhwui would double-free Atlas::mImage. This lead to a lot of crashes
    with the monkeys as they can easily trigger memory trims.
    
    Change-Id: I96798414e5e71cd498aaca85a790661ebccdaa91

[33mcommit 72bd95b8feb7ef41eb5dd00003b1aed8f30f4abe[m
Merge: 94268b0 b90ff50
Author: Romain Guy <romainguy@google.com>
Date:   Mon May 6 13:56:23 2013 -0700

    am b90ff505: am fdf13c90: Merge "Convert alpha from [0..1] to [0.255] range Bug #8808886" into jb-mr2-dev
    
    * commit 'b90ff505df143abd957cfc19b60727e3460ee68c':
      Convert alpha from [0..1] to [0.255] range Bug #8808886

[33mcommit 94268b0dd908ea003772e24bec12cea473434486[m
Merge: 7caa1a8 33be275
Author: Chet Haase <chet@google.com>
Date:   Mon May 6 13:56:20 2013 -0700

    am 33be275d: am d65eebf4: Merge "Fix scaled-view droppings artifact" into jb-mr2-dev
    
    * commit '33be275deb072ca3e6155b61370578b16dbee64a':
      Fix scaled-view droppings artifact

[33mcommit 1f8a0db348f6c7bf2d1f55065472c913677f3d69[m
Author: Romain Guy <romainguy@google.com>
Date:   Mon May 6 11:15:28 2013 -0700

    Remove stray log
    
    Change-Id: I392eea216ad67f376ded802c19a3e2287aacc6f8

[33mcommit fdf13c90cb6b412dd93ae6a8990bf962e0d71407[m
Merge: d65eebf 87b515c
Author: Romain Guy <romainguy@google.com>
Date:   Sat May 4 01:42:46 2013 +0000

    Merge "Convert alpha from [0..1] to [0.255] range Bug #8808886" into jb-mr2-dev

[33mcommit 87b515cde53f3c8cc3fdf698c100e67508487e59[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri May 3 17:42:27 2013 -0700

    Convert alpha from [0..1] to [0.255] range
    Bug #8808886
    
    Without this conversion, alpha was always set to 0 or 1 which causes
    things to disappear mysteriously. Mysteries are meant to be solved
    and I solved them all in 6 characters.
    
    Change-Id: I2078420fbe968c046e999b0eabb24403e71108fd

[33mcommit 78dd96d5af20f489f0e8b288617d57774ec284f7[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri May 3 14:24:16 2013 -0700

    Add an on-screen overdraw counter
    
    The counter can be enabled by setting the system property called
    debug.hwui.overdraw to the string "count". If the string is set
    to "show", overdraw will be highlighted on screen instead of
    printing out a simple counter.
    
    Change-Id: I9a9c970d54bffab43138bbb7682f6c04bc2c40bd

[33mcommit 259b696b00f07938569fc9a0ea43858cdaab909b[m
Author: Chet Haase <chet@google.com>
Date:   Fri May 3 15:25:33 2013 -0700

    Fix scaled-view droppings artifact
    
    Sometimes views that are scaled leave behind rows/columns on the
    screen as they move/scale around.
    
    The problem was that the pivot point around which the scale takes place
    (in the default case of scaling around the center of the view)
    was getting truncated to integer coordinates in the display list.
    Meanwhile, the pivot point at the Java level was using the true float
    values, resulting in a mis-match between the invalidation rectangle
    (computed at the Java level) and the drawing-operation rectangle (computed
    at the native level).
    
    This only occurred when views had odd bounds (thus the integer representation
    of the center differed from the float representation of the center), and only
    when some other drawing operation would expand the clip rect to allow the
    incorrect drawing operation (using the wrong pivot point) to draw outside of
    its clip boundaries.
    
    Issue #8617023 7x7 screen not updated correctly
    
    Change-Id: If88889b9450d34535df732b78077a29b1f24802d

[33mcommit 1212c9dafe932f70956651338568c5e1fdf21bcf[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu May 2 17:50:23 2013 -0700

    Remove warning
    
    Change-Id: Ia1523d02dc2b7f58ca26a142a5aef710792a5f3d

[33mcommit 877cfe0e32a845d5a58252b8a6e1f54f95b4379c[m
Author: Romain Guy <romainguy@google.com>
Date:   Thu May 2 17:36:28 2013 -0700

    Wrap EGLImage with a C++ API
    
    Change-Id: I0fa3282ea7e2ace3ba2aadd929b32232b3d41628

[33mcommit 3b748a44c6bd2ea05fe16839caf73dbe50bd7ae9[m
Author: Romain Guy <romainguy@google.com>
Date:   Wed Apr 17 18:54:38 2013 -0700

    Pack preloaded framework assets in a texture atlas
    
    When the Android runtime starts, the system preloads a series of assets
    in the Zygote process. These assets are shared across all processes.
    Unfortunately, each one of these assets is later uploaded in its own
    OpenGL texture, once per process. This wastes memory and generates
    unnecessary OpenGL state changes.
    
    This CL introduces an asset server that provides an atlas to all processes.
    
    Note: bitmaps used by skia shaders are *not* sampled from the atlas.
    It's an uncommon use case and would require extra texture transforms
    in the GL shaders.
    
    WHAT IS THE ASSETS ATLAS
    
    The "assets atlas" is a single, shareable graphic buffer that contains
    all the system's preloaded bitmap drawables (this includes 9-patches.)
    The atlas is made of two distinct objects: the graphic buffer that
    contains the actual pixels and the map which indicates where each
    preloaded bitmap can be found in the atlas (essentially a pair of
    x and y coordinates.)
    
    HOW IS THE ASSETS ATLAS GENERATED
    
    Because we need to support a wide variety of devices and because it
    is easy to change the list of preloaded drawables, the atlas is
    generated at runtime, during the startup phase of the system process.
    
    There are several steps that lead to the atlas generation:
    
    1. If the device is booting for the first time, or if the device was
    updated, we need to find the best atlas configuration. To do so,
    the atlas service tries a number of width, height and algorithm
    variations that allows us to pack as many assets as possible while
    using as little memory as possible. Once a best configuration is found,
    it gets written to disk in /data/system/framework_atlas
    
    2. Given a best configuration (algorithm variant, dimensions and
    number of bitmaps that can be packed in the atlas), the atlas service
    packs all the preloaded bitmaps into a single graphic buffer object.
    
    3. The packing is done using Skia in a temporary native bitmap. The
    Skia bitmap is then copied into the graphic buffer using OpenGL ES
    to benefit from texture swizzling.
    
    HOW PROCESSES USE THE ATLAS
    
    Whenever a process' hardware renderer initializes its EGL context,
    it queries the atlas service for the graphic buffer and the map.
    
    It is important to remember that both the context and the map will
    be valid for the lifetime of the hardware renderer (if the system
    process goes down, all apps get killed as well.)
    
    Every time the hardware renderer needs to render a bitmap, it first
    checks whether the bitmap can be found in the assets atlas. When
    the bitmap is part of the atlas, texture coordinates are remapped
    appropriately before rendering.
    
    Change-Id: I8eaecf53e7f6a33d90da3d0047c5ceec89ea3af0

[33mcommit 69ca575b5bdfa023858db3fff11ec5c2a7b277a9[m
Merge: a2e56c5 4a2bff7
Author: Chris Craik <ccraik@google.com>
Date:   Wed Apr 24 17:44:46 2013 +0000

    Merge "Avoid incorrectly dirtying the functor output rect"

[33mcommit 4a2bff7b387403ac976cd041cb5a1b57afa44d9c[m
Author: Chris Craik <ccraik@google.com>
Date:   Tue Apr 16 13:50:16 2013 -0700

    Avoid incorrectly dirtying the functor output rect
    
    bug:8640186
    Change-Id: I360cb85e59cfdd0b499561e92b81089341d07046

[33mcommit 684634144b15e4da0ed04baa2c4531ef538652a6[m
Merge: f986ecf 371d4cc
Author: Chet Haase <chet@google.com>
Date:   Sat Apr 20 21:37:23 2013 -0700

    am 371d4ccc: am 339ac854: Merge "Fix quickReject logic to account for setClipChildren() setting" into jb-mr2-dev
    
    * commit '371d4cccde56ec4d26e51f8e82ef68f196169a3d':
      Fix quickReject logic to account for setClipChildren() setting

[33mcommit dd671599bed9d3ca28e2c744e8c224e1e15bc914[m
Author: Chet Haase <chet@google.com>
Date:   Fri Apr 19 14:54:34 2013 -0700

    Fix quickReject logic to account for setClipChildren() setting
    
    The rendering code optimizes by rejecting drawing operations that
    lie outside of the bounds of their views. This works in most
    situations, but breaks down when containers have called
    setClipChildren(false), because we reject drawing that is outside
    of that container, but which should be drawn anyway.
    
    Fix is to pass in the value of that flag to the DisplayList drawing
    routines which take that flag into account when deciding whether
    to quickReject any particular operation.
    
    Issue #8659277 animation clipping
    
    Change-Id: Ief568e4db01b533a97b3c5ea5ad777c03c0eea71

[33mcommit e0cedc40a2c6671370fd0c434874e7e79c0ba71f[m
Merge: 341a31b 17917a9
Author: Chris Craik <ccraik@google.com>
Date:   Thu Apr 18 13:51:57 2013 -0700

    am 17917a95: am d3f9ffe2: Merge "Prevent transformed ops from merging in the first place" into jb-mr2-dev
    
    * commit '17917a95f355634ba881cd3f587002cb7ef27ce6':
      Prevent transformed ops from merging in the first place

[33mcommit d3f9ffe28d1599e40f8c9a7c0c32465324bb2828[m
Merge: 5d1a182 ee5b2c6
Author: Chris Craik <ccraik@google.com>
Date:   Thu Apr 18 20:43:24 2013 +0000

    Merge "Prevent transformed ops from merging in the first place" into jb-mr2-dev

[33mcommit ee5b2c6de7fb32d945a5a1303012a5f94b719dfa[m
Author: Chris Craik <ccraik@google.com>
Date:   Thu Apr 18 12:57:07 2013 -0700

    Prevent transformed ops from merging in the first place
    
    bug:8649215
    
    Previously we prevented ops with non-translate transforms from
    merging, but missed the case of the first op in a merging batch
    containing a non-translate transform.
    
    This fulfills the assumption of drawText's non-immediate mode that
    merged ops will have pure translate transforms.
    
    Change-Id: I6f6db341aff3f7e84e74b4c3ccf970d585a2db1a

[33mcommit e76dd37bdb75e7ed757e1284249c64f0c58e869d[m
Merge: d05849e 680ca94
Author: Chris Craik <ccraik@google.com>
Date:   Tue Apr 16 18:02:31 2013 -0700

    am 680ca941: am ec5dc76a: Merge "Make layer double drawing visible in overdraw debug mode" into jb-mr2-dev
    
    * commit '680ca9418b6b3f01547b286d1a80e07e186bc05f':
      Make layer double drawing visible in overdraw debug mode

[33mcommit 34416eaa1c07b3d7a139e780cea8f8d73219650e[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Apr 15 16:08:28 2013 -0700

    Make layer double drawing visible in overdraw debug mode
    
    A clipped saveLayer will cause two draws - first to an onscreen
    buffer, then again back to the framebuffer. This change - when in
    overdraw debug - reissues draws associated with a clipped saveLayer,
    but only to the stencil buffer. Operations within a saveLayer are
    shown correctly to be twice drawn, and View.setAlpha() without an
    associated hardware layer, or hasOverlappingRendering() are made more
    visible.
    
    Hardware layers, on any frame that they are updated, similarly draw
    twice, and will also be counted against the stencil buffer doubly.
    
    Note: greater depths of layers - e.g. a saveLayer within a saveLayer -
    are not respected, as that would require additional region tracking.
    
    Change-Id: I61fb0e61038fe66013d59914c20bb47a550dea7d

[33mcommit 09d3636485eb1601c5beaf0d8682bb3027d2271d[m
Author: Romain Guy <romainguy@google.com>
Date:   Tue Apr 16 11:30:05 2013 -0700

    Fix indentation
    
    Change-Id: If54b7d7c016acb5e7300323d2eada57142a814c0

[33mcommit 55709fc1c7b2741ba3cf7f160d7d8644c112bb99[m
Merge: 647e4b8 55b883b
Author: Chris Craik <ccraik@google.com>
Date:   Mon Apr 15 14:34:35 2013 -0700

    am 55b883b0: am 30c990c3: Merge "Draw Operation merging" into jb-mr2-dev
    
    * commit '55b883b0a960b37aa453253f3ccb614dd95c221c':
      Draw Operation merging

[33mcommit 30c990c361291ad578ef4ffe4a4dd0fd6080797b[m
Merge: 3f1375e 527a3aa
Author: Chris Craik <ccraik@google.com>
Date:   Mon Apr 15 21:27:10 2013 +0000

    Merge "Draw Operation merging" into jb-mr2-dev

[33mcommit 527a3aace1dd72432c2e0472a570e030ad04bf16[m
Author: Chris Craik <ccraik@google.com>
Date:   Mon Mar 4 10:19:31 2013 -0800

    Draw Operation merging
    
    Merge simple bitmap draw operations and text operations to avoid
    issuing individual gl draws for each operation. Merging other ops to
    be done eventually.
    
    The methods are different - the bitmap merging generates a single
    mesh for reused, unclipped images (esp. repeated images in a listview)
    
    The text approach queries just defers the normal font rendering until
    the last drawText in the sequence that can share the same shader.
    
    Patches are sorted and merged, but don't yet have a multiDraw
    implementation. For now, the pretending-to-merge gives better sorting
    behavior by keeping similar patches together.
    
    Change-Id: Ic300cdab0a53814cf7b09c58bf54b1bf0f58ccd6

[33mcommit 5069101c08ff11e78bfab7eeb7360b0b12e3b54b[m
Merge: b2d17bc 5141bf8
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 12 18:05:48 2013 -0700

    am 5141bf80: am 80fccb4d: Merge "There should be a mandatory coder\'s license. Bug #8586560" into jb-mr2-dev
    
    * commit '5141bf801e9d58e618c76e4cdc042218b24193fc':
      There should be a mandatory coder's license. Bug #8586560

[33mcommit 4abab937bf3f168763a7c029275bf1de151ec1ae[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 12 16:51:21 2013 -0700

    There should be a mandatory coder's license.
    Bug #8586560
    
    And I don't deserve to pass the test.
    
    Change-Id: Ic7886205511f16145a925fc860e4a03dfaf473d5

[33mcommit 0f6ba077321ef275649fdcc29c0b323e9740d739[m
Merge: f0dffd0 543c5dc
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 12 16:49:14 2013 -0700

    am 543c5dcf: am efcb252f: Merge "Properly computer gradient textures width" into jb-mr2-dev
    
    * commit '543c5dcfcb93925a5b9ac073eedb0bd813b2ebe0':
      Properly computer gradient textures width

[33mcommit 95aeff8f11968c8b29ae114bb5e1172c70cf7634[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 12 16:32:05 2013 -0700

    Properly computer gradient textures width
    
    Only on devices that do not have the npot extension
    
    Change-Id: I472a13dc707d2abaf5fcc06f99c9da343b333558

[33mcommit e48da96ab5837f305ef55d5ea9d3215930884f83[m
Merge: 28da134 886e120
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 12 11:00:21 2013 -0700

    resolved conflicts for merge of 886e1204 to master
    
    Change-Id: Id002d2ae799c6946672335f122ecbfa07d9c0bc1

[33mcommit cf51a4199835e9604aa4c8b3854306f8fbabbf33[m
Author: Romain Guy <romainguy@google.com>
Date:   Mon Apr 8 19:40:31 2013 -0700

    Introduce PixelBuffer API to enable PBOs
    
    PBOs (Pixel Buffer Objects) can be used on OpenGL ES 3.0 to perform
    asynchronous texture uploads to free up the CPU. This change does not
    enable the use of PBOs unless a specific property is set (Adreno drivers
    have issues with PBOs at the moment, Mali drivers work just fine.)
    
    This change also cleans up Font/FontRenderer a little bit and improves
    performance of drop shadows generations by using memcpy() instead of
    a manual byte-by-byte copy.
    
    On GL ES 2.0 devices, or when PBOs are disabled, a PixelBuffer instance
    behaves like a simple byte array. The extra APIs introduced for PBOs
    (map/unmap and bind/unbind) are pretty much no-ops for CPU pixel
    buffers and won't introduce any significant overhead.
    
    This change also fixes a bug with text drop shadows: if the drop
    shadow is larger than the max texture size, the renderer would leave
    the GL context in a bad state and generate 0x501 errors. This change
    simply skips drop shadows if they are too large.
    
    Change-Id: I2700aadb0c6093431dc5dee3d587d689190c4e23

[33mcommit c4c8f2d82e4d047c479fbdad5e1e296d745bfe3b[m
Merge: 229f1aa 78b24b6
Author: Chet Haase <chet@google.com>
Date:   Wed Apr 10 11:01:31 2013 -0700

    am 78b24b6f: am dacd4751: Merge "Fix Contacts animation jank" into jb-mr2-dev
    
    * commit '78b24b6f03f467a59afd6797b4c03224fe3af767':
      Fix Contacts animation jank

[33mcommit dacd47516321d263efa7489b5b9bd7d8e1714332[m
Merge: 8f980e1 58d110a
Author: Chet Haase <chet@google.com>
Date:   Wed Apr 10 17:48:53 2013 +0000

    Merge "Fix Contacts animation jank" into jb-mr2-dev

[33mcommit 58d110afa0e0f3843d72617046185a3c2d48dca9[m
Author: Chet Haase <chet@google.com>
Date:   Wed Apr 10 07:43:29 2013 -0700

    Fix Contacts animation jank
    
    The last frame of an animation stays stuck on the screen for a couple of frames.
    Specifically, the "Quick Contact" animation that animates the picture
    closed (fades/scales it away) animates all the way to the end... then hangs there
    briefly before being taken down.
    
    The problem is a rendering bug where we correctly detect that a DisplayList
    has nothing to draw (since the last frame is completely transparent, alpha==0),
    but incorrectly ignore the fact that we cleared the transparent-background
    window prior to not-drawing that DisplayList. When we detect that there's
    nothing to draw, we don't bother swapping buffers. So even though we drew
    the right thing (clearing the buffer), we didn't actually post the buffer to the
    screen.
    
    This change factors in both the clear and the draw to decide when to swap buffers.
    
    Issue #8564865 Quick contact close animation jank redux
    
    Change-Id: Ib922cff88a94f025b62f7461c1a29e96fe454838

[33mcommit 28af35e8cdc601c7ab9c7287d9e72fdc331e8a9d[m
Merge: 171af24 a976bdd
Author: Ying Wang <wangying@google.com>
Date:   Tue Apr 9 23:21:42 2013 -0700

    resolved conflicts for merge of a976bddd to master
    
    Change-Id: I64e1cbfb0eee891ce4d1eee40eefdcedcc501f7f

[33mcommit d8b26d6c424741dd09cf70ee88fd237807aaf301[m
Merge: 07c6fa1 d685894
Author: Ying Wang <wangying@google.com>
Date:   Wed Apr 10 05:16:14 2013 +0000

    Merge "Add liblog" into jb-mr2-dev

[33mcommit d685894212e6dbeac1fda4996903c1da115d49a6[m
Author: Ying Wang <wangying@google.com>
Date:   Tue Apr 9 21:54:12 2013 -0700

    Add liblog
    
    Bug: 8580410
    Change-Id: I746aa8258866508c3a725d0773faf4518096548f

[33mcommit 6c825d49b77b1b257b59a30c24792d1bf0f5df84[m
Merge: 24fafc4 52706c6
Author: Romain Guy <romainguy@google.com>
Date:   Tue Apr 9 14:26:10 2013 -0700

    am 52706c6c: am 4a745e78: Merge "Change the dither texture\'s swizzling" into jb-mr2-dev
    
    * commit '52706c6cc0d8ded20cfa8d46f200ca38f1009468':
      Change the dither texture's swizzling

[33mcommit 032d47af737d803e841ab79f38ac9068a46c9aeb[m
Author: Romain Guy <romainguy@google.com>
Date:   Mon Apr 8 19:45:40 2013 -0700

    Change the dither texture's swizzling
    
    This is a more elegant way to sample from a float alpha texture.
    Instead of sampling from the red channel in the fragment shader
    we can set the alpha channel swizzle to redirect it to the
    red channel. This lets us sample from the alpha channel in the
    fragment shader and get the correct value.
    
    Change-Id: I95bbf7a82964e1bf42c0fee1b782b6bdbbcef618

[33mcommit 6adbb9033502d98b77176a2fe4001f37d177d78c[m
Merge: 6d2ea1f 5ea0465
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 5 15:46:37 2013 -0700

    am 5ea0465d: am 8299f683: Merge "Use float textures to render gradients when possible" into jb-mr2-dev
    
    * commit '5ea0465d4550944e2e5ac953a5c18ef31f31ec4d':
      Use float textures to render gradients when possible

[33mcommit b48800428906ae455c2b63acacd44e390e1fee49[m
Author: Romain Guy <romainguy@google.com>
Date:   Fri Apr 5 11:17:55 2013 -0700

    Use float textures to render gradients when possible
    
    Float textures offer better precision for dithering.
    
    In addition this change removes two uniforms from gradient shaders.
    These uniforms were used to dither gradients but their value is
    a build time constant. Instead we hardcode the value directly in
    the shader source at compile time.
    
    Change-Id: I05e9fd3eef93771843bbd91b453274452dfaefee

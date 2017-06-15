var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#LibHealpix.jl-Documentation-1",
    "page": "Home",
    "title": "LibHealpix.jl Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "getting-started.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting-started.html#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": ""
},

{
    "location": "cookbook.html#",
    "page": "Cookbook",
    "title": "Cookbook",
    "category": "page",
    "text": ""
},

{
    "location": "cookbook.html#Cookbook-1",
    "page": "Cookbook",
    "title": "Cookbook",
    "category": "section",
    "text": ""
},

{
    "location": "cookbook.html#Creating-a-Map-1",
    "page": "Cookbook",
    "title": "Creating a Map",
    "category": "section",
    "text": "using LibHealpix\nnside = 16\nmap = HealpixMap(Float64, nside)\nfor i = 1:length(map)\n    map[i] = i\nend"
},

{
    "location": "cookbook.html#Spherical-Harmonic-Transforms-1",
    "page": "Cookbook",
    "title": "Spherical Harmonic Transforms",
    "category": "section",
    "text": "using LibHealpix\nlmax = mmax = 10\nalm = Alm(Complex128, lmax, mmax)\nfor m = 0:mmax, l = m:lmax\n    alm[l,m] = l + m\nend\nnside = 16\nmap = alm2map(alm, nside)\nblm = map2alm(map, lmax, mmax)"
},

{
    "location": "cookbook.html#FITS-I/O-1",
    "page": "Cookbook",
    "title": "FITS I/O",
    "category": "section",
    "text": "using LibHealpix\nmap = readhealpix(\"map.fits\")\nwritehealpix(\"othermap.fits\", map)"
},

{
    "location": "cookbook.html#Visualization-1",
    "page": "Cookbook",
    "title": "Visualization",
    "category": "section",
    "text": "using LibHealpix\nusing PyPlot # for imshow(...)\nmap = HealpixMap(Float64, nside)\nfor i = 1:length(map)\n    map[i] = rand()\nend\nimg = mollweide(map)\nimshow(img)"
},

{
    "location": "library.html#",
    "page": "Library",
    "title": "Library",
    "category": "page",
    "text": ""
},

{
    "location": "library.html#Library-1",
    "page": "Library",
    "title": "Library",
    "category": "section",
    "text": "CurrentModule = LibHealpix\nDocTestSetup = quote\n    using LibHealpix\nend"
},

{
    "location": "library.html#LibHealpix.nside2npix",
    "page": "Library",
    "title": "LibHealpix.nside2npix",
    "category": "Function",
    "text": "nside2npix(nside)\n\nCompute the number of pixels in a Healpix map with the given value of nside.\n\nArguments:\n\nnside - the Healpix resolution parameter\n\nUsage:\n\njulia> nside2npix(4)\n192\n\njulia> nside2npix(256)\n786432\n\nSee Also: npix2nside, nside2nring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.npix2nside",
    "page": "Library",
    "title": "LibHealpix.npix2nside",
    "category": "Function",
    "text": "npix2nside(npix)\n\nCompute the value of the nside parameter for a Healpix map with the given number of pixels.\n\nArguments:\n\nnpix - the number of pixels in the map\n\nUsage:\n\njulia> npix2nside(192)\n4\n\njulia> npix2nside(786432)\n256\n\nSee Also: nside2npix, nside2nring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.nside2nring",
    "page": "Library",
    "title": "LibHealpix.nside2nring",
    "category": "Function",
    "text": "nside2nring(nside)\n\nCompute the number of equal latitude rings in the Healpix map with the given value of nside.\n\nArguments:\n\nnside - the Healpix resolution parameter\n\nUsage:\n\njulia> nside2nring(4)\n15\n\njulia> nside2nring(256)\n1023\n\nSee Also: nside2npix, npix2nside\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.ang2vec",
    "page": "Library",
    "title": "LibHealpix.ang2vec",
    "category": "Function",
    "text": "ang2vec(theta, phi)\n\nCompute the Cartesian unit vector to the spherical coordinates ( ).\n\nArguments:\n\ntheta - the inclination angle \nphi - the azimuthal angle \n\nUsage:\n\njulia> ang2vec(0, 0)\n3-element LibHealpix.UnitVector:\n 0.0\n 0.0\n 1.0\n\njulia> ang2vec(π/2, π/2)\n3-element LibHealpix.UnitVector:\n 6.12323e-17\n 1.0\n 6.12323e-17\n\nSee Also: vec2ang\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.vec2ang",
    "page": "Library",
    "title": "LibHealpix.vec2ang",
    "category": "Function",
    "text": "vec2ang(vec)\n\nCompute the spherical coordinates ( ) from the given unit vector.\n\nArguments:\n\nvec - the input Cartesian unit vector\n\nUsage:\n\njulia> vec2ang([1, 0, 0])\n(1.5707963267948966, 0.0)\n\njulia> vec2ang([0, 1, 0])\n(1.5707963267948966, 1.5707963267948966)\n\njulia> vec2ang([0, 0, 1])\n(0.0, 0.0)\n\nSee Also: ang2vec\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.nest2ring",
    "page": "Library",
    "title": "LibHealpix.nest2ring",
    "category": "Function",
    "text": "nest2ring(nside, ipix)\n\nConvert the given pixel index from the nested to the ring indexing scheme.\n\nArguments:\n\nnside - the Healpix resolution parameter\nipix - the pixel index (nested scheme)\n\nUsage:\n\njulia> nest2ring(256, 1)\n391809\n\njulia> nest2ring(256, 2)\n390785\n\nSee Also: ring2nest\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.ring2nest",
    "page": "Library",
    "title": "LibHealpix.ring2nest",
    "category": "Function",
    "text": "ring2nest(nside, ipix)\n\nConvert the given pixel index from the ring to the nested indexing scheme.\n\nArguments:\n\nnside - the Healpix resolution parameter\nipix - the pixel index (ring scheme)\n\nUsage:\n\njulia> ring2nest(256, 1)\n65536\n\njulia> ring2nest(256, 2)\n131072\n\nSee Also: nest2ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.ang2pix_nest",
    "page": "Library",
    "title": "LibHealpix.ang2pix_nest",
    "category": "Function",
    "text": "ang2pix_nest(nside, theta, phi)\n\nCompute the pixel index (in the nested scheme) that contains the point on the sphere given by the spherical coordinates ( ).\n\nArguments:\n\nnside - the Healpix resolution parameter\ntheta - the inclination angle \nphi - the azimuthal angle \n\nUsage:\n\njulia> ang2pix_nest(256, 0, 0)\n65536\n\njulia> ang2pix_nest(256, π/2, π/2)\n354987\n\nSee Also: ang2pix_ring, pix2ang_nest, pix2ang_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.ang2pix_ring",
    "page": "Library",
    "title": "LibHealpix.ang2pix_ring",
    "category": "Function",
    "text": "ang2pix_ring(nside, theta, phi)\n\nCompute the pixel index (in the ring scheme) that contains the point on the sphere given by the spherical coordinates ( ).\n\nArguments:\n\nnside - the Healpix resolution parameter\ntheta - the inclination angle \nphi - the azimuthal angle \n\nUsage:\n\njulia> ang2pix_ring(256, 0, 0)\n1\n\njulia> ang2pix_ring(256, π/2, π/2)\n392961\n\nSee Also: ang2pix_nest, pix2ang_nest, pix2ang_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.pix2ang_nest",
    "page": "Library",
    "title": "LibHealpix.pix2ang_nest",
    "category": "Function",
    "text": "pix2ang_nest(nside, ipix)\n\nCompute the spherical coordinates ( ) corresponding to the given pixel center.\n\nArguments:\n\nnside - the Healpix resolution parameter\nipix - the pixel index (nested scheme)\n\nUsage:\n\njulia> pix2ang_nest(256, 1)\n(1.5681921571847817, 0.7853981633974483)\n\njulia> pix2ang_nest(256, 2)\n(1.5655879699137618, 0.7884661249732196)\n\nSee Also: pix2ang_ring, ang2pix_nest, ang2pix_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.pix2ang_ring",
    "page": "Library",
    "title": "LibHealpix.pix2ang_ring",
    "category": "Function",
    "text": "pix2ang_ring(nside, ipix)\n\nCompute the spherical coordinates ( ) corresponding to the given pixel center.\n\nArguments:\n\nnside - the Healpix resolution parameter\nipix - the pixel index (ring scheme)\n\nUsage:\n\njulia> pix2ang_ring(256, 1)\n(0.0031894411211228764, 0.7853981633974483)\n\njulia> pix2ang_ring(256, 2)\n(0.0031894411211228764, 2.356194490192345)\n\nSee Also: pix2ang_nest, ang2pix_nest, ang2pix_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.vec2pix_nest",
    "page": "Library",
    "title": "LibHealpix.vec2pix_nest",
    "category": "Function",
    "text": "vec2pix_nest(nside, vec)\n\nCompute the pixel index (in the nested scheme) that contains the point on the sphere given by the Cartesian unit vector.\n\nArguments:\n\nnside - the Healpix resolution parameter\nvec - the input Cartesian unit vector\n\nUsage:\n\njulia> vec2pix_nest(256, [1, 0, 0])\n289451\n\njulia> vec2pix_nest(256, [0, 1, 0])\n354987\n\njulia> vec2pix_nest(256, [0, 0, 1])\n65536\n\nSee Also: vec2pix_ring, pix2vec_nest, pix2vec_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.vec2pix_ring",
    "page": "Library",
    "title": "LibHealpix.vec2pix_ring",
    "category": "Function",
    "text": "vec2pix_ring(nside, vec)\n\nCompute the pixel index (in the ring scheme) that contains the point on the sphere given by the Cartesian unit vector.\n\nArguments:\n\nnside - the Healpix resolution parameter\nvec - the input Cartesian unit vector\n\nUsage:\n\njulia> vec2pix_ring(256, [1, 0, 0])\n392705\n\njulia> vec2pix_ring(256, [0, 1, 0])\n392961\n\njulia> vec2pix_ring(256, [0, 0, 1])\n1\n\nSee Also: vec2pix_nest, pix2vec_nest, pix2vec_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.pix2vec_nest",
    "page": "Library",
    "title": "LibHealpix.pix2vec_nest",
    "category": "Function",
    "text": "pix2vec_nest(nside, ipix)\n\nCompute the Cartesian unit vector corresponding to the given pixel center.\n\nArguments:\n\nnside - the Healpix resolution parameter\nipix - the pixel index (nested scheme)\n\nUsage:\n\njulia> pix2vec_nest(256, 1)\n3-element LibHealpix.UnitVector:\n 0.707104\n 0.707104\n 0.00260417\n\njulia> pix2vec_nest(256, 2)\n3-element LibHealpix.UnitVector:\n 0.704925\n 0.709263\n 0.00520833\n\nSee Also: pix2vec_ring, vec2pix_nest, vec2pix_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.pix2vec_ring",
    "page": "Library",
    "title": "LibHealpix.pix2vec_ring",
    "category": "Function",
    "text": "pix2vec_ring(nside, ipix)\n\nCompute the Cartesian unit vector corresponding to the given pixel center.\n\nArguments:\n\nnside - the Healpix resolution parameter\nipix - the pixel index (ring scheme)\n\nUsage:\n\njulia> pix2vec_ring(256, 1)\n3-element LibHealpix.UnitVector:\n 0.00225527\n 0.00225527\n 0.999995\n\njulia> pix2vec_ring(256, 2)\n3-element LibHealpix.UnitVector:\n -0.00225527\n  0.00225527\n  0.999995\n\nSee Also: pix2vec_nest, vec2pix_nest, vec2pix_ring\n\n\n\n"
},

{
    "location": "library.html#Pixel-Functions-1",
    "page": "Library",
    "title": "Pixel Functions",
    "category": "section",
    "text": "nside2npix\nnpix2nside\nnside2nring\nang2vec\nvec2ang\nnest2ring\nring2nest\nang2pix_nest\nang2pix_ring\npix2ang_nest\npix2ang_ring\nvec2pix_nest\nvec2pix_ring\npix2vec_nest\npix2vec_ring"
},

{
    "location": "library.html#LibHealpix.HealpixMap",
    "page": "Library",
    "title": "LibHealpix.HealpixMap",
    "category": "Type",
    "text": "abstract type HealpixMap{T<:Number} <: AbstractVector{T}\n\nThis abstract type represents a Healpix equal-area pixelization of the sphere.\n\nSubtypes:\n\nRingHealpixMap - a HealpixMap where pixels are ordered along rings of constant   latitude. This ordering should be used for performing spherical harmonic transforms.\nNestHealpixMap - a HealpixMap where nearby pixels also tend to be nearby in memory.\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.RingHealpixMap",
    "page": "Library",
    "title": "LibHealpix.RingHealpixMap",
    "category": "Type",
    "text": "struct RingHealpixMap{T<:Number} <: HealpixMap{T}\n\nThis type represents a Healpix equal-area pixelization of the sphere where pixels are ordered along rings of constant latitude.\n\nFields:\n\nnside - the Healpix resolution parameter\npixels - the list of pixel values\n\nConstructors:\n\nRingHealpixMap(T, nside)\n\nConstruct a RingHealpixMap with the element type T and resolution parameter nside. All of the pixels will be set to zero initially.\n\nRingHealpixMap(pixels)\n\nConstruct a RingHealpixMap with the given list of pixel values. The resolution parameter nside will be inferred from the number of pixels. However a LibHealpixException will be thrown if given an invalid number of pixels.\n\nRingHealpixMap(nside, pixels)\n\nConstruct a RingHealpixMap with the given resolution parameter nside and initial list of pixel values. This constructor is cheaper than RingHealpixMap(pixels) if the correct value of nside is already known.\n\nUsage:\n\njulia> map = RingHealpixMap(Float64, 256)\n       for idx = 1:length(map)\n           map[idx] = randn()\n       end\n       map + map == 2map\ntrue\n\nSee also: HealpixMap, NestHealpixMap, Alm\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.NestHealpixMap",
    "page": "Library",
    "title": "LibHealpix.NestHealpixMap",
    "category": "Type",
    "text": "struct NestHealpixMap{T<:Number} <: HealpixMap{T}\n\nThis type represents a Healpix equal-area pixelization of the sphere where nearby pixels also tend to be nearby in memory.\n\nFields:\n\nnside - the Healpix resolution parameter\npixels - the list of pixel values\n\nConstructors:\n\nNestHealpixMap(T, nside)\n\nConstruct a NestHealpixMap with the element type T and resolution parameter nside. All of the pixels will be set to zero initially.\n\nNestHealpixMap(pixels)\n\nConstruct a NestHealpixMap with the given list of pixel values. The resolution parameter nside will be inferred from the number of pixels. However a LibHealpixException will be thrown if given an invalid number of pixels.\n\nNestHealpixMap(nside, pixels)\n\nConstruct a NestHealpixMap with the given resolution parameter nside and initial list of pixel values. This constructor is cheaper than NestHealpixMap(pixels) if the correct value of nside is already known.\n\nUsage:\n\njulia> map = NestHealpixMap(Float64, 256)\n       for idx = 1:length(map)\n           map[idx] = randn()\n       end\n       map + map == 2map\ntrue\n\nSee also: HealpixMap, RingHealpixMap, Alm\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.writehealpix",
    "page": "Library",
    "title": "LibHealpix.writehealpix",
    "category": "Function",
    "text": "writehealpix(filename, map)\n\nWrite the HealpixMap to disk as a FITS image.\n\nArguments\n\nfilename - the name of the output file (eg. \"/path/to/healpix.fits\")\nmap - the Healpix map to write\n\nKeyword Arguments\n\ncoordsys - the coordinate system of the map (one of \"G\" galactic, \"E\" ecliptic, or \"C\"   celestial)\nreplace - if set to true, the output file will be automatically overwritten if it exists\n\nSee also: readhealpix\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.readhealpix",
    "page": "Library",
    "title": "LibHealpix.readhealpix",
    "category": "Function",
    "text": "readhealpix(filename)\n\nRead a HealpixMap (stored as a FITS image) from disk.\n\nArguments\n\nfilename - the name of the input file (eg. \"/path/to/healpix.fits\")\n\nSee also: writehealpix\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.ang2pix",
    "page": "Library",
    "title": "LibHealpix.ang2pix",
    "category": "Function",
    "text": "ang2pix(map, theta, phi)\n\nCompute the pixel index that contains the point on the sphere given by the spherical coordinates ( ).\n\nArguments:\n\nmap - the input Healpix map\ntheta - the inclination angle \nphi - the azimuthal angle \n\nUsage:\n\njulia> ang2pix(RingHealpixMap(Float64, 256), π/2, π/2)\n392961\n\njulia> ang2pix(NestHealpixMap(Float64, 256), π/2, π/2)\n354987\n\nSee Also: pix2ang, ang2pix_nest, ang2pix_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.pix2ang",
    "page": "Library",
    "title": "LibHealpix.pix2ang",
    "category": "Function",
    "text": "pix2ang(map, ipix)\n\nCompute the spherical coordinates ( ) corresponding to the given pixel center.\n\nArguments:\n\nmap - the input Healpix map\nipix - the pixel index\n\nUsage:\n\njulia> pix2ang(RingHealpixMap(Float64, 256), 1)\n(0.0031894411211228764, 0.7853981633974483)\n\njulia> pix2ang(NestHealpixMap(Float64, 256), 1)\n(1.5681921571847817, 0.7853981633974483)\n\nSee Also: ang2pix, pix2ang_nest, pix2ang_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.vec2pix",
    "page": "Library",
    "title": "LibHealpix.vec2pix",
    "category": "Function",
    "text": "vec2pix(map, vec)\n\nCompute the pixel index that contains the point on the sphere given by the Cartesian unit vector.\n\nArguments:\n\nmap - the input Healpix map\nvec - the input Cartesian unit vector\n\nUsage:\n\njulia> vec2pix(RingHealpixMap(Float64, 256), [0, 0, 1])\n1\n\njulia> vec2pix(NestHealpixMap(Float64, 256), [0, 0, 1])\n65536\n\nSee Also: pix2vec, vec2pix_nest, vec2pix_ring\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.pix2vec",
    "page": "Library",
    "title": "LibHealpix.pix2vec",
    "category": "Function",
    "text": "pix2vec(map, ipix)\n\nCompute the Cartesian unit vector corresponding to the given pixel center.\n\nArguments:\n\nmap - the input Healpix map\nipix - the pixel index (nested scheme)\n\nUsage:\n\njulia> pix2vec(RingHealpixMap(Float64, 256), 1)\n3-element LibHealpix.UnitVector:\n 0.00225527\n 0.00225527\n 0.999995\n\njulia> pix2vec(NestHealpixMap(Float64, 256), 1)\n3-element LibHealpix.UnitVector:\n 0.707104\n 0.707104\n 0.00260417\n\nSee Also: vec2pix, pix2vec_nest, pix2vec_ring\n\n\n\n"
},

{
    "location": "library.html#Healpix-Maps-1",
    "page": "Library",
    "title": "Healpix Maps",
    "category": "section",
    "text": "HealpixMap\nRingHealpixMap\nNestHealpixMap\nwritehealpix\nreadhealpix\nang2pix\npix2ang\nvec2pix\npix2vec"
},

{
    "location": "library.html#LibHealpix.Alm",
    "page": "Library",
    "title": "LibHealpix.Alm",
    "category": "Type",
    "text": "struct Alm{T<:Number} <: AbstractVector{T}\n\nThis type holds a vector of spherical harmonic coefficients.\n\nFields:\n\nlmax - the maximum value for the l quantum number\nmmax - the maximum value for the m quantum number (note that m  l)\ncoefficients - the list of spherical harmonic coefficients\n\nConstructors:\n\nAlm(T, lmax, mmax)\n\nConstruct an Alm object that will store all spherical harmonic coefficients with element type T, l  l, and m  m. All of the coefficients will be initialized to zero.\n\nAlm(lmax, mmax, coefficients)\n\nConstruct an Alm object with the given list of initial coefficients corresponding to l  l, and m  m. A LibHealpixException will be thrown if too many or too few coefficients are provided.\n\nUsage:\n\njulia> alm = Alm(Complex128, 10, 10)\n       for (l, m) in lm(alm)\n           @lm alm[l, m] = l * m\n       end\n       @lm(alm[10, 5]) == 50\ntrue\n\nnote: Note\nThe lm function is used to iterate over the spherical harmonic quantum numbers l and m.\n\nnote: Note\nThe @lm macro is used to index into an Alm object when given the spherical harmonic quantum numbers l and m.\n\nSee also: RingHealpixMap, NestHealpixMap, lm, @lm\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.lm",
    "page": "Library",
    "title": "LibHealpix.lm",
    "category": "Function",
    "text": "lm(lmax, mmax)\nlm(alm)\n\nConstruct an interator for iterating over all possible values of the spherical harmonic quantum numbers l  l and m  m.\n\nArguments:\n\nlmax - the maximum value of l\nmmax - the maximum value of m\nalm - if an Alm object is provided, lmax and mmax will be inferred from the corresponding   fields\n\nUsage:\n\njulia> for (l, m) in lm(2, 1)\n           @show l, m\n       end\n(l, m) = (0, 0)\n(l, m) = (1, 0)\n(l, m) = (2, 0)\n(l, m) = (1, 1)\n(l, m) = (2, 1)\n\nSee Also: Alm, @lm\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.@lm",
    "page": "Library",
    "title": "LibHealpix.@lm",
    "category": "Macro",
    "text": "@lm\n\nThis macro is used to index an Alm object when given the values for quantum numbers l and m.\n\nUsage\n\njulia> alm = Alm(Int, 2, 1)\n       for (l, m) in lm(alm)\n           @lm alm[l, m] = l + m\n       end\n\njulia> @lm alm[1, 1]\n2\n\njulia> @lm alm[1, :] # all coefficients with l == 1\n2-element Array{Int64,1}:\n 1\n 2\n\njulia> @lm alm[:, 1] # all coefficients with m == 1\n2-element Array{Int64,1}:\n 2\n 3\n\nBackground\n\nAlm implements the AbstractVector interface which allows the type to be used in place of a standard Vector in many cases. This generally makes sense because Alm is simply a wrapper around a standard Vector.\n\nHowever, one consequence of being an AbstractVector is that the two-element getindex function already has a meaning and therefore alm[l, m] cannot be used to mean \"give me the coefficient corresponding to the quantum numbers l and m\". Instead @lm alm[l, m] calls a separate function that does give you the coefficient for l and m.\n\nSee Also: Alm, lm\n\n\n\n"
},

{
    "location": "library.html#Spherical-Harmonic-Coefficients-1",
    "page": "Library",
    "title": "Spherical Harmonic Coefficients",
    "category": "section",
    "text": "Alm\nlm\n@lm"
},

{
    "location": "library.html#LibHealpix.map2alm",
    "page": "Library",
    "title": "LibHealpix.map2alm",
    "category": "Function",
    "text": "map2alm(map, lmax, mmax)\n\nCompute the spherical harmonic coefficients of the given Healpix map by means of a spherical harmonic transform.\n\nArguments:\n\nmap - the input Healpix map (must be ring ordered)\nlmax - the maximum value for the l quantum number\nmmax - the maximum value for the m quantum number\n\nKeyword Arguments:\n\niterations - the number of iterations to perform\n\nnote: Note\nSet iterations to something greater than 0 if more precision is required.\n\nUsage:\n\njulia> map = RingHealpixMap(Float64, 4)\n       map[:] = 1\n       alm = map2alm(map, 1, 1)\n       @lm alm[0, 0]\n3.5449077018110318 + 0.0im\n\nSee Also: alm2map\n\n\n\n"
},

{
    "location": "library.html#LibHealpix.alm2map",
    "page": "Library",
    "title": "LibHealpix.alm2map",
    "category": "Function",
    "text": "alm2map(alm, nside)\n\nCompute the Healpix map corresponding to the given spherical harmonic coefficients by means of an inverse spherical harmonic transform.\n\nArguments:\n\nalm - the input list of spherical harmonic coefficients\nnside - the resolution of the output Healpix map\n\nUsage:\n\njulia> alm = Alm(Complex128, 1, 1)\n       @lm alm[0, 0] = 1\n       map = alm2map(alm, 1)\n12-element LibHealpix.RingHealpixMap{Float64}:\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n 0.282095\n\nSee Also: map2alm\n\n\n\n"
},

{
    "location": "library.html#Spherical-Harmonic-Transforms-1",
    "page": "Library",
    "title": "Spherical Harmonic Transforms",
    "category": "section",
    "text": "map2alm\nalm2map"
},

{
    "location": "library.html#LibHealpix.mollweide",
    "page": "Library",
    "title": "LibHealpix.mollweide",
    "category": "Function",
    "text": "mollweide(map, size=(512, 1024))\n\nCreate a Mollweide projected image of the given Healpix map.\n\nnote: Note\nThe image values will be set to zero outside of the projection area.\n\nArguments:\n\nmap - the input Healpix map\nsize - the size of the output image\n\nUsage:\n\njulia> map = RingHealpixMap(Int, 1)\n       map[:] = 1\n       mollweide(map, (10, 20))\n10×20 Array{Int64,2}:\n 0  0  0  0  0  0  1  1  1  1  1  1  1  1  0  0  0  0  0  0\n 0  0  0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0  0  0\n 0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0\n 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1\n 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1\n 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1\n 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1\n 0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0\n 0  0  0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0  0  0\n 0  0  0  0  0  0  1  1  1  1  1  1  1  1  0  0  0  0  0  0\n\n\n\n"
},

{
    "location": "library.html#Visualization-1",
    "page": "Library",
    "title": "Visualization",
    "category": "section",
    "text": "mollweide"
},

]}

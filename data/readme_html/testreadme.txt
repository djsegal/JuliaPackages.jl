<div id="readme" class="md" data-path="README.md"><article class="markdown-body entry-content container-lg" itemprop="text"><div class="markdown-heading" dir="auto"><h1 class="heading-element" dir="auto">TestReadme.jl</h1><a id="user-content-testreadmejl" class="anchor" aria-label="Permalink: TestReadme.jl" href="#testreadmejl"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></div>
<p dir="auto"><a href="https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml?query=branch%3Amain"><img src="https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml/badge.svg?branch=main" alt="Build status" style="max-width: 100%;"></a> <a href="https://codecov.io/gh/thchr/TestReadme.jl" rel="nofollow"><img src="https://camo.githubusercontent.com/db27da4aa1fd88aa78390b931d8001b4eaf7f99c6ab56d5d6cc57c559c9d9ae5/68747470733a2f2f636f6465636f762e696f2f67682f74686368722f54657374526561646d652e6a6c2f6272616e63682f6d61696e2f67726170682f62616467652e737667" alt="Coverage" data-canonical-src="https://codecov.io/gh/thchr/TestReadme.jl/branch/main/graph/badge.svg" style="max-width: 100%;"></a></p>
<p dir="auto">This package provides a macro <code>@test_readme path</code> which extracts all Julia code snippets of the following form</p>
<div class="highlight highlight-text-md notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="```jl 
julia&gt; input
output
```"><pre><span class="pl-s">```</span><span class="pl-en">jl</span> 
julia<span class="pl-k">&gt;</span> input
output
<span class="pl-s">```</span></pre></div>
<p dir="auto">from a file at <code>path</code>, comparing <code>repr(MIME(text/plain), input)</code> against <code>output</code> for each such input-output pair.</p>
<p dir="auto">The purpose of TestReadme.jl is two-fold:</p>
<ol dir="auto">
<li>Automatically turn README examples into unit tests.</li>
<li>Ensure that README examples stay synced with package functionality.</li>
</ol>
<p dir="auto">Additional <code>@test_readme</code> details:</p>
<ul dir="auto">
<li>If omitted, <code>path</code> defaults to <code>(@__DIR__)/../README.md</code> (i.e., default Julia project structure).</li>
<li>If no <code>output</code> is featured in the code snippet, it is simply tested that <code>input</code> evaluates without error.</li>
<li>If evaluation of the README code snippets requires specific packages, load them <em>before</em> calling <code>@test_readme</code>.</li>
<li>Results are aggregated in a single <code>@testset</code>, named <code>"README tests"</code>.</li>
</ul>
<div class="markdown-heading" dir="auto"><h2 class="heading-element" dir="auto">Example: README snippets tested by <code>@test_readme</code></h2><a id="user-content-example-readme-snippets-tested-by-test_readme" class="anchor" aria-label="Permalink: Example: README snippets tested by @test_readme" href="#example-readme-snippets-tested-by-test_readme"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></div>
<p dir="auto">The following code snippets form part of the test suite of TestReadme.jl itself (see <a href="https://github.com/thchr/TestReadme.jl/blob/main/test/runtests.jl"><code>/test/runtests.jl</code></a>).</p>
<p dir="auto">A basic test of math output:</p>
<div class="highlight highlight-source-julia notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="julia&gt; cos(π)
-1.0
julia&gt; sum([1,2,3])
6"><pre>julia<span class="pl-k">&gt;</span> <span class="pl-c1">cos</span>(π)
<span class="pl-k">-</span><span class="pl-c1">1.0</span>
julia<span class="pl-k">&gt;</span> <span class="pl-c1">sum</span>([<span class="pl-c1">1</span>,<span class="pl-c1">2</span>,<span class="pl-c1">3</span>])
<span class="pl-c1">6</span></pre></div>
<p dir="auto">A test of string outputs:</p>
<div class="highlight highlight-source-julia notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="julia&gt; join([&quot;abc&quot;, &quot;xyz&quot;], &quot; and &quot;)
&quot;abc and xyz&quot;"><pre>julia<span class="pl-k">&gt;</span> <span class="pl-c1">join</span>([<span class="pl-s"><span class="pl-pds">"</span>abc<span class="pl-pds">"</span></span>, <span class="pl-s"><span class="pl-pds">"</span>xyz<span class="pl-pds">"</span></span>], <span class="pl-s"><span class="pl-pds">"</span> and <span class="pl-pds">"</span></span>)
<span class="pl-s"><span class="pl-pds">"</span>abc and xyz<span class="pl-pds">"</span></span></pre></div>
<p dir="auto">It is also possible to chain commands and define variables; a variable defined in one code snippet is in scope throughout a <code>@test_readme</code> call:</p>
<div class="highlight highlight-source-julia notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="julia&gt; x = 2
2
julia&gt; x += 3
julia&gt; x
5"><pre>julia<span class="pl-k">&gt;</span> x <span class="pl-k">=</span> <span class="pl-c1">2</span>
<span class="pl-c1">2</span>
julia<span class="pl-k">&gt;</span> x <span class="pl-k">+=</span> <span class="pl-c1">3</span>
julia<span class="pl-k">&gt;</span> x
<span class="pl-c1">5</span></pre></div>
<p dir="auto">Similarly, a single</p>
<div class="highlight highlight-source-julia notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="julia&gt; begin
y = 2
z = y+x
end
7
julia&gt; exp(z)
1096.6331584284585"><pre>julia<span class="pl-k">&gt;</span> <span class="pl-k">begin</span>
y <span class="pl-k">=</span> <span class="pl-c1">2</span>
z <span class="pl-k">=</span> y<span class="pl-k">+</span>x
<span class="pl-k">end</span>
<span class="pl-c1">7</span>
julia<span class="pl-k">&gt;</span> <span class="pl-c1">exp</span>(z)
<span class="pl-c1">1096.6331584284585</span></pre></div>
<div class="markdown-heading" dir="auto"><h3 class="heading-element" dir="auto">Inspecting extracted code-snippets</h3><a id="user-content-inspecting-extracted-code-snippets" class="anchor" aria-label="Permalink: Inspecting extracted code-snippets" href="#inspecting-extracted-code-snippets"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="m7.775 3.275 1.25-1.25a3.5 3.5 0 1 1 4.95 4.95l-2.5 2.5a3.5 3.5 0 0 1-4.95 0 .751.751 0 0 1 .018-1.042.751.751 0 0 1 1.042-.018 1.998 1.998 0 0 0 2.83 0l2.5-2.5a2.002 2.002 0 0 0-2.83-2.83l-1.25 1.25a.751.751 0 0 1-1.042-.018.751.751 0 0 1-.018-1.042Zm-4.69 9.64a1.998 1.998 0 0 0 2.83 0l1.25-1.25a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042l-1.25 1.25a3.5 3.5 0 1 1-4.95-4.95l2.5-2.5a3.5 3.5 0 0 1 4.95 0 .751.751 0 0 1-.018 1.042.751.751 0 0 1-1.042.018 1.998 1.998 0 0 0-2.83 0l-2.5 2.5a1.998 1.998 0 0 0 0 2.83Z"></path></svg></a></div>
<p dir="auto">The extracted input-output pairs can be obtained and inspected via <code>parse_readme(path)</code>:</p>
<div class="highlight highlight-source-julia notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="julia&gt; m = TestReadme # pick your module
julia&gt; path = joinpath(pkgdir(m), &quot;README.md&quot;)
julia&gt; input_outputs = parse_readme(path)"><pre>julia<span class="pl-k">&gt;</span> m <span class="pl-k">=</span> TestReadme <span class="pl-c"><span class="pl-c">#</span> pick your module</span>
julia<span class="pl-k">&gt;</span> path <span class="pl-k">=</span> <span class="pl-c1">joinpath</span>(<span class="pl-c1">pkgdir</span>(m), <span class="pl-s"><span class="pl-pds">"</span>README.md<span class="pl-pds">"</span></span>)
julia<span class="pl-k">&gt;</span> input_outputs <span class="pl-k">=</span> <span class="pl-c1">parse_readme</span>(path)</pre></div>
<p dir="auto">With the last line here printing (not included as output in the above above to avoid recursive madness):</p>
<div class="highlight highlight-source-julia notranslate position-relative overflow-auto" dir="auto" data-snippet-clipboard-copy-content="11-element Vector{InputOutput}:
 :(cos(π)) ⇒ -1.0
 :(sum([1, 2, 3])) ⇒ 6
 :(join([&quot;abc&quot;, &quot;xyz&quot;], &quot; and &quot;)) ⇒ &quot;abc and xyz&quot;
 :(x = 2) ⇒ 2
 :(x += 3) ⇒ &quot;&quot;
 :(x) ⇒ 5
 :(begin\n y = 2\n z = y + x\n end) ⇒ 7
 :(exp(z)) ⇒ 1096.6331584284585
 :(m = TestReadme) ⇒ &quot;&quot;
 :(path = joinpath(pkgdir(m), &quot;README.md&quot;)) ⇒ &quot;&quot;
 :(input_outputs = parse_readme(path)) ⇒ &quot;&quot;"><pre><span class="pl-c1">11</span><span class="pl-k">-</span>element Vector{InputOutput}<span class="pl-k">:</span>
 :(<span class="pl-c1">cos</span>(π)) <span class="pl-k">⇒</span> <span class="pl-k">-</span><span class="pl-c1">1.0</span>
 :(<span class="pl-c1">sum</span>([<span class="pl-c1">1</span>, <span class="pl-c1">2</span>, <span class="pl-c1">3</span>])) <span class="pl-k">⇒</span> <span class="pl-c1">6</span>
 :(<span class="pl-c1">join</span>([<span class="pl-s"><span class="pl-pds">"</span>abc<span class="pl-pds">"</span></span>, <span class="pl-s"><span class="pl-pds">"</span>xyz<span class="pl-pds">"</span></span>], <span class="pl-s"><span class="pl-pds">"</span> and <span class="pl-pds">"</span></span>)) <span class="pl-k">⇒</span> <span class="pl-s"><span class="pl-pds">"</span>abc and xyz<span class="pl-pds">"</span></span>
 :(x <span class="pl-k">=</span> <span class="pl-c1">2</span>) <span class="pl-k">⇒</span> <span class="pl-c1">2</span>
 :(x <span class="pl-k">+=</span> <span class="pl-c1">3</span>) <span class="pl-k">⇒</span> <span class="pl-s"><span class="pl-pds">"</span><span class="pl-pds">"</span></span>
 :(x) <span class="pl-k">⇒</span> <span class="pl-c1">5</span>
 :(<span class="pl-k">begin</span><span class="pl-k">\</span>n y <span class="pl-k">=</span> <span class="pl-c1">2</span><span class="pl-k">\</span>n z <span class="pl-k">=</span> y <span class="pl-k">+</span> x<span class="pl-k">\</span>n <span class="pl-k">end</span>) <span class="pl-k">⇒</span> <span class="pl-c1">7</span>
 :(<span class="pl-c1">exp</span>(z)) <span class="pl-k">⇒</span> <span class="pl-c1">1096.6331584284585</span>
 :(m <span class="pl-k">=</span> TestReadme) <span class="pl-k">⇒</span> <span class="pl-s"><span class="pl-pds">"</span><span class="pl-pds">"</span></span>
 :(path <span class="pl-k">=</span> <span class="pl-c1">joinpath</span>(<span class="pl-c1">pkgdir</span>(m), <span class="pl-s"><span class="pl-pds">"</span>README.md<span class="pl-pds">"</span></span>)) <span class="pl-k">⇒</span> <span class="pl-s"><span class="pl-pds">"</span><span class="pl-pds">"</span></span>
 :(input_outputs <span class="pl-k">=</span> <span class="pl-c1">parse_readme</span>(path)) <span class="pl-k">⇒</span> <span class="pl-s"><span class="pl-pds">"</span><span class="pl-pds">"</span></span></pre></div>
</article></div>
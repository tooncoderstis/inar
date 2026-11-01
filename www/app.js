(function () {
  function typesetMath() {
    if (window.MathJax && window.MathJax.typesetPromise) {
      window.MathJax.typesetPromise().catch(function () {});
    }
  }

  function activateTabFromQuery() {
    var params = new URLSearchParams(window.location.search);
    var tab = params.get("tab");
    if (!tab) return;
    var link = document.querySelector('.navbar-nav a[data-value="' + tab + '"]');
    if (link) link.click();
  }

  document.addEventListener("DOMContentLoaded", function () {
    activateTabFromQuery();
    setTimeout(typesetMath, 400);
    setTimeout(typesetMath, 1500);
  });

  document.addEventListener("shown.bs.tab", function () {
    setTimeout(typesetMath, 120);
  });

  if (window.Shiny) {
    document.addEventListener("shiny:connected", function () {
      setTimeout(typesetMath, 800);
    });
  }

  document.addEventListener("keydown", function (e) {
    if (!document.getElementById("pdf-canvas")) return;
    if (e.target && /input|textarea|select/i.test(e.target.tagName)) return;
    if (e.key === "ArrowRight" && window.pdfNext) window.pdfNext();
    if (e.key === "ArrowLeft" && window.pdfPrev) window.pdfPrev();
  });
})();

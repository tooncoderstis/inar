(function () {
  let pdfDoc = null;
  let pageNum = 1;
  let scale = 1.35;
  let rendering = false;

  function el(id) {
    return document.getElementById(id);
  }

  function setLoading(text) {
    const node = el("pdf-loading");
    if (node) {
      node.textContent = text;
      node.style.display = text ? "block" : "none";
    }
  }

  function renderPage() {
    if (!pdfDoc || rendering) return;
    rendering = true;
    pdfDoc.getPage(pageNum).then(function (page) {
      const canvas = el("pdf-canvas");
      if (!canvas) return;
      const viewport = page.getViewport({ scale: scale });
      canvas.width = Math.floor(viewport.width);
      canvas.height = Math.floor(viewport.height);
      const ctx = canvas.getContext("2d");
      return page.render({ canvasContext: ctx, viewport: viewport }).promise.then(function () {
        const label = el("pdf-page");
        if (label) label.textContent = pageNum + " / " + pdfDoc.numPages;
        rendering = false;
      });
    }).catch(function (err) {
      rendering = false;
      setLoading("Gagal merender halaman: " + err.message);
    });
  }

  window.initPdfViewer = function (url) {
    if (!window.pdfjsLib) {
      setLoading("PDF.js tidak termuat.");
      return;
    }
    window.pdfjsLib.GlobalWorkerOptions.workerSrc = "vendor/pdfjs/pdf.worker.min.js";
    setLoading("Memuat dokumen...");
    window.pdfjsLib.getDocument({ url: url, withCredentials: true }).promise.then(function (pdf) {
      pdfDoc = pdf;
      pageNum = 1;
      setLoading("");
      renderPage();
    }).catch(function (err) {
      setLoading("Gagal memuat PDF: " + err.message);
    });
  };

  window.pdfNext = function () {
    if (pdfDoc && pageNum < pdfDoc.numPages) {
      pageNum += 1;
      renderPage();
    }
  };

  window.pdfPrev = function () {
    if (pdfDoc && pageNum > 1) {
      pageNum -= 1;
      renderPage();
    }
  };

  window.pdfZoom = function (delta) {
    scale = Math.min(3, Math.max(0.6, scale + delta));
    renderPage();
  };

  if (window.Shiny) {
    Shiny.addCustomMessageHandler("loadPdf", function (msg) {
      setTimeout(function () { window.initPdfViewer(msg.url); }, 250);
    });
  }
})();

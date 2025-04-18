document.addEventListener("turbo:load", () => {
    $(".select2").select2({
      tags: true,
      tokenSeparators: [','],
      width: '100%',
      placeholder: "Add skills"
    });
  });
  
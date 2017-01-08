var host, uploadAttachment;

document.addEventListener("trix-attachment-add", function(event) {
  var attachment;
  attachment = event.attachment;
  host = event.srcElement.dataset.attachmentPath;

  if (attachment.file) {
    return uploadAttachment(attachment);
  }
});

uploadAttachment = function(attachment) {
  var file, form, key, xhr;
  file = attachment.file;
  form = new FormData;
  form.append("Content-Type", file.type);
  form.append("authenticity_token", document.querySelector("meta[name='csrf-token']").content);
  form.append("[file_attachment]file", file);
  xhr = new XMLHttpRequest;
  xhr.open("POST", host, true);
  xhr.upload.onprogress = function(event) {
    var progress;
    progress = event.loaded / event.total * 100;
    return attachment.setUploadProgress(progress);
  };
  xhr.onload = function() {
    var href, url;
    if (xhr.status === 200) {
      url = href = xhr.responseText;
      return attachment.setAttributes({
        url: url,
        href: href
      });
    }
  };
  return xhr.send(form);
};

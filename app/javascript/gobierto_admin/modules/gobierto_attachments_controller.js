import Vue from "vue";
Vue.config.productionTip = false;

window.GobiertoAdmin.GobiertoAttachmentsController = (function() {
  function GobiertoAttachmentsController() {}

  GobiertoAttachmentsController.prototype.index = function(attachmentsCollectionId) {
    app(attachmentsCollectionId);
  };

  function onlyUnique(value, index, self) {
    return self.indexOf(value) === index;
  }

  function app(attachmentsCollectionId) {
    var bus = new Vue({});

    var STATUS_INITIAL = 0,
      STATUS_SAVING = 1,
      STATUS_SUCCESS = 2,
      STATUS_FAILED = 3;

    var fileUtils = {
      methods: {
        fileExtension: function(name) {
          return name
            .split(".")
            .pop()
            .toUpperCase();
        },
        bytesToSize: function(bytes) {
          var sizes = ["bytes", "Kb", "Mb", "Gb", "Tb"];
          if (bytes == 0) return "0 Byte";
          var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
          return Math.round(bytes / Math.pow(1024, i), 2) + " " + sizes[i];
        }
      }
    };

    var magnificPopup = {
      methods: {
        closeModal: function() {
          if (!$.magnificPopup.instance.isOpen && !this.showModal) {
            return;
          }
          this.showModal = false;
          $.magnificPopup.close();
        },
        openModal: function() {
          var self = this;
          self.showModal = true;
          var config = {
            mainClass: "mfp-move-horizontal",
            items: {
              src: $(self.$refs.modal),
              type: "inline"
            },
            callbacks: {
              close: self.closeModal
            }
          };
          $.magnificPopup.open(config);
          $('input.slim').focus();
        }
      }
    };

    Vue.component("file-upload", {
      template: "#file-upload",
      data: function() {
        return {
          fileDragged: false,
          uploadedFiles: [],
          uploadError: null,
          currentStatus: null,
          uploadFieldName: "attachment",
          attachment: {},
          errorMessage: null,
          isDragged: false,
          collectionId: attachmentsCollectionId
        };
      },
      computed: {
        isInitial: function() {
          return this.currentStatus === STATUS_INITIAL;
        },
        isSaving: function() {
          return this.currentStatus === STATUS_SAVING;
        },
        isSuccess: function() {
          return this.currentStatus === STATUS_SUCCESS;
        },
        isFailed: function() {
          return this.currentStatus === STATUS_FAILED;
        }
      },
      methods: {
        dragEntered: function() {
          this.isDragged = true;
        },
        dragLeft: function() {
          this.isDragged = false;
        },
        reset: function() {
          // reset form to initial state
          this.currentStatus = STATUS_INITIAL;
          this.uploadedFiles = [];
          this.uploadError = null;
          this.attachment = {};
          this.fileDragged = false;
        },
        save: function() {
          // upload data to the server
          this.currentStatus = STATUS_SAVING;

          this.upload(function(file) {
            this.uploadedFiles = [file];
            this.currentStatus = STATUS_SUCCESS;
          });
        },
        upload: function(callback) {
          var self = this;
          $.ajax({
            url: "/admin/attachments/api/attachments",
            dataType: "json",
            method: "POST",
            data: {
              attachment: self.attachment
            },
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function() {
              bus.$emit("site-attachments:load");
            },
            error: function(jqXHR) {
              self.errorMessage = jqXHR.responseJSON.error;
              setTimeout(function() {
                self.errorMessage = null;
              }, 2000);
            },
            complete: function() {
              self.reset();
              bus.$emit("file-upload:fileDraggedUpdated", self.fileDragged);
            }
          });
          callback();
        },
        filesChange: function(fieldName, fileList) {
          if (!fileList.length) return;

          this.fileDragged = true;
          this.attachment.file_name = fileList[0].name;
          this.attachment.collection_id = this.collectionId;
          bus.$emit("file-upload:fileDraggedUpdated", this.fileDragged);
          bus.$emit("site-attachments:load");

          var reader = new FileReader();
          var self = this;
          reader.addEventListener(
            "load",
            function() {
              self.attachment.file = reader.result.split(",")[1];
            },
            false
          );
          reader.readAsDataURL(fileList[0]);
        }
      },
      mounted: function() {
        this.reset();
      }
    });

    Vue.component("edit-attachment", {
      template: "#edit-attachment",
      mixins: [fileUtils, magnificPopup],
      data: function() {
        return {
          showModal: false,
          attachment: null
        };
      },
      mounted: function() {
        var self = this;
        bus.$on("edit-attachment:load", function(data) {
          self.fetchData(data.id);
        });
      },
      methods: {
        fetchData: function(id) {
          var self = this;
          $.ajax({
            url: "/admin/attachments/api/attachments/" + id,
            dataType: "json",
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function(response, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                Vue.set(self, "attachment", response.attachment);
                self.openModal();
              }
            }
          });
        },
        updateAttachment: function(id) {
          var self = this;
          $.ajax({
            url: "/admin/attachments/api/attachments/" + id,
            method: "PATCH",
            data: {
              attachment: {
                name: self.attachment !== null ? self.attachment.name : "",
                description: self.attachment !== null ? self.attachment.description : ""
              }
            },
            dataType: "json",
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function(response, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                bus.$emit("file-popover:load", { id: self.attachment.id });
                self.closeModal();
                bus.$emit("file-list:load");
              }
            }
          });
        },
        attachmentDoc: function(attachment) {
          if (attachment) return attachment.file_name + " (" + this.bytesToSize(attachment.file_size) + ")";
          else return "";
        }
      }
    });

    Vue.component("file-popover", {
      template: "#file-popover",
      mixins: [fileUtils],
      props: ["attachableId", "attachableType"],
      data: function() {
        return {
          show: false,
          attachment: null,
          copySuccessful: false
        };
      },
      mounted: function() {
        var self = this;
        bus.$on("file-popover:load", function(data) {
          self.fetchData(data.id);
        });
      },
      watch: {
        copySuccessful: function(newValue) {
          if (newValue === true) {
            var that = this;
            setTimeout(function() {
              that.copySuccessful = false;
            }, 2000);
          }
        }
      },
      methods: {
        closePopover: function() {
          this.show = false;
        },
        fetchData: function(id) {
          var self = this;
          $.ajax({
            url: "/admin/attachments/api/attachments/" + id,
            dataType: "json",
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function(response, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                Vue.set(self, "attachment", response.attachment);
                Vue.set(self, "show", true);
              }
            }
          });
        },
        editAttachment: function(id) {
          bus.$emit("edit-attachment:load", { id: id });
        },
        removeAttaching: function() {
          var self = this;
          if (self.attachableId === "") {
            bus.$emit("file-popover:removeAttaching", self.attachment);
            Vue.set(self, "show", false);
            return;
          }

          $.ajax({
            url: "/admin/attachments/api/attachings",
            method: "DELETE",
            dataType: "json",
            data: {
              attachment_id: self.attachment.id,
              attachable_id: self.attachableId,
              attachable_type: self.attachableType
            },
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function(response, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                Vue.set(self, "show", false);
                bus.$emit("file-list:load");
              }
            }
          });
        },
        addToEditor: function(attachment) {
          var locale = $("[data-toggle-edit-locale].selected").data("toggle-edit-locale");
          var localeSuffix = "";
          if (locale !== undefined) localeSuffix = "[lang=" + locale + "]";
          var element = $("[data-wysiwyg]" + localeSuffix);
          if (element.length) {
            var html;

            var imageExtensions = ["JPG", "JPEG", "PNG", "GIF", "BMP", "TIFF"];
            if (imageExtensions.indexOf(this.fileExtension(attachment.file_name)) != -1) {
              html = "![](" + attachment.human_readable_url + ")";
            } else {
              html =
                '<a href="' +
                attachment.human_readable_url +
                '" target="_blank">' +
                attachment.file_name +
                ' <span class="size">(' +
                this.bytesToSize(attachment.file_size) +
                ")</span></a>" +
                "\n";
            }

            var editor = element.data("editor");
            var doc = (doc = editor.codemirror.getDoc());
            var cursor = doc.getCursor();
            doc.replaceRange(html, cursor);
          }
        },
        copyUrlToClipboard: function(attachment) {
          var textArea = document.createElement("textarea");
          textArea.value = attachment.human_readable_url;
          document.body.appendChild(textArea);
          textArea.select();

          try {
            this.copySuccessful = document.execCommand("copy");
          } catch (err) {
            this.copySuccessful = false;
          }
          document.body.removeChild(textArea);
        }
      }
    });

    Vue.component("site-attachments", {
      template: "#site-attachments",
      mixins: [fileUtils, magnificPopup],
      props: ["attachableId", "attachableType"],
      data: function() {
        return {
          q: "",
          previousQ: "",
          attachments: [],
          showModal: false,
          fileDragged: false
        };
      },
      methods: {
        searchStringParameters: function() {
          if (this.q === "") return {};
          return { search_string: this.q };
        },
        formatDate: function(date) {
          if (date === undefined || date === null) return "";
          return I18n.l("date.formats.short", date);
        },
        fetchData: function() {
          var self = this;
          $.ajax({
            url: "/admin/attachments/api/attachments",
            dataType: "json",
            data: this.searchStringParameters(),
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function(response, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                Vue.set(self, "attachments", response.attachments);
                self.openModal();
              }
            }
          });
        },
        associateAttachment: function(attachment) {
          var self = this;
          if (this.attachableId === "") {
            bus.$emit("site-attachments:newAttaching", attachment);
            self.closeModal();
            return;
          }
          $.ajax({
            url: "/admin/attachments/api/attachings",
            dataType: "json",
            method: "POST",
            data: {
              attachment_id: attachment.id,
              attachable_id: this.attachableId,
              attachable_type: this.attachableType
            },
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function() {
              bus.$emit("file-list:load");
            },
            complete: function() {
              self.closeModal();
            }
          });
        },
        search: function() {
          if (this.q.length > 2) {
            this.fetchData(this.q);
          } else if (this.previousQ != this.q) {
            this.fetchData();
          }
          this.previousQ = this.q;
        }
      },
      mounted: function() {
        var self = this;
        bus.$on("site-attachments:load", function() {
          self.fetchData();
        });
        bus.$on("file-upload:fileDraggedUpdated", function(value) {
          self.fileDragged = value;
        });
      }
    });

    Vue.component("file-list", {
      props: ["attachableId", "attachableType"],
      mixins: [fileUtils],
      template: "#file-list-template",
      data: function() {
        return {
          attachments: [],
          showFiles: true
        };
      },
      computed: {
        fileListClass: function() {
          if (this.attachments.length == 0) return "";

          if (this.showFiles) return "fa-caret-down";
          else return "fa-caret-right";
        }
      },
      methods: {
        popover: function(e) {
          bus.$emit("file-popover:load", { id: $(e.target).data("attachment-id") });
        },
        fetchData: function() {
          var self = this;
          if (this.attachableId === "") return;
          $.ajax({
            url: "/admin/attachments/api/attachments",
            data: {
              attachable_type: this.attachableType,
              attachable_id: this.attachableId
            },
            dataType: "json",
            beforeSend: function(xhr) {
              xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr("content"));
            },
            success: function(response, textStatus, jqXHR) {
              if (jqXHR.status == 200) {
                Vue.set(self, "attachments", response.attachments);
                if (response.attachments.length > 0) {
                  self.showFiles = true;
                } else {
                  self.showFiles = false;
                }
              }
            }
          });
        },
        toggleList: function() {
          this.showFiles = !this.showFiles;
        }
      },
      mounted: function() {
        var self = this;
        self.fetchData();
        bus.$on("file-list:load", function() {
          self.fetchData();
          self.showFiles = true;
        });
        bus.$on("site-attachments:newAttaching", function(attachment) {
          self.attachments.push(attachment);
          self.attachments = self.attachments.filter(onlyUnique);
          self.showFiles = true;
        });
        bus.$on("file-popover:removeAttaching", function(attachment) {
          var index = -1;
          self.attachments.forEach(function(a, i) {
            if (a.id === attachment.id) index = i;
          });
          self.attachments.splice(index, 1);
          self.showFiles = true;
        });
      }
    });

    // start app
    var selector = "#gobierto-attachment";
    new Vue({
      el: selector,
      data: {
        attachmentsIdsAfterCreated: [],
        attachmentsIdsAfterCreatedStr: "",
        attachableType: $(selector).data("attachable-type"),
        attachableId: $(selector).data("attachable-id")
      },
      methods: {
        loadAttachments: function() {
          bus.$emit("site-attachments:load");
        }
      },
      mounted: function() {
        var self = this;
        bus.$on("site-attachments:newAttaching", function(attachment) {
          self.attachmentsIdsAfterCreated.push(attachment.id);
          self.attachmentsIdsAfterCreatedStr = self.attachmentsIdsAfterCreated.join(",");
          $("#attachmentsIdsAfterCreated").val(self.attachmentsIdsAfterCreatedStr);
        });
        bus.$on("file-popover:removeAttaching", function(attachment) {
          var index = -1;
          self.attachmentsIdsAfterCreated.forEach(function(a, i) {
            if (a.id === attachment.id) index = i;
          });
          self.attachmentsIdsAfterCreated.splice(index, 1);
          self.attachmentsIdsAfterCreatedStr = self.attachmentsIdsAfterCreated.join(",");
          $("#attachmentsIdsAfterCreated").val(self.attachmentsIdsAfterCreatedStr);
        });
      }
    });
  }

  return GobiertoAttachmentsController;
})();

window.GobiertoAdmin.gobierto_attachments_controller = new GobiertoAdmin.GobiertoAttachmentsController();

this.GobiertoAdmin.GobiertoAttachmentsController = (function() {
  function GobiertoAttachmentsController() {}

  GobiertoAttachmentsController.prototype.index = function() {
    app();
  };

  function app() {
    var bus = new Vue({});

    const STATUS_INITIAL = 0, STATUS_SAVING = 1,
          STATUS_SUCCESS = 2, STATUS_FAILED = 3;

    var fileUtils = {
      methods: {
        fileExtension: function(name){
          if(name.indexOf('.') !== -1){
            return name.split('.')[1].toUpperCase();
          } else {
            return name.toUpperCase();
          }
        },
        bytesToSize: function(bytes) {
          var sizes = ['bytes', 'Kb', 'Mb', 'Gb', 'Tb'];
          if (bytes == 0) return '0 Byte';
          var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
          return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
        }
      }
    }

    Vue.component('file-upload', {
      template: '#file-upload',
      data: function(){
        return {
          fileDragged: false,
          uploadedFiles: [],
          uploadError: null,
          currentStatus: null,
          uploadFieldName: 'attachment',
          attachment: {},
          errorMessage: null
        }
      },
      computed: {
        isInitial() {
          return this.currentStatus === STATUS_INITIAL;
        },
        isSaving() {
          return this.currentStatus === STATUS_SAVING;
        },
        isSuccess() {
          return this.currentStatus === STATUS_SUCCESS;
        },
        isFailed() {
          return this.currentStatus === STATUS_FAILED;
        }
      },
      methods: {
        reset() {
          // reset form to initial state
          this.currentStatus = STATUS_INITIAL;
          this.uploadedFiles = [];
          this.uploadError = null;
          this.attachment = {};
          this.fileDragged = false;
        },
        save() {
          // upload data to the server
          this.currentStatus = STATUS_SAVING;

          this.upload(function(file){
            this.uploadedFiles = [file];
            this.currentStatus = STATUS_SUCCESS;
          });
        },
        upload: function(callback){
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachments',
            dataType: 'json',
            method: "POST",
            data: {
              attachment: self.attachment
            },
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              bus.$emit('site-attachments:load');
            },
            error: function(jqXHR, textStatus, errorThrown){
              self.errorMessage = jqXHR.responseJSON.error;
            },
            complete: function(){
              self.reset();
              bus.$emit('file-upload:fileDraggedUpdated', self.fileDragged);
            }
          });
          callback();
        },
        filesChange: function(fieldName, fileList) {
          if (!fileList.length) return;

          this.fileDragged = true;
          this.attachment.file_name = fileList[0].name;
          bus.$emit('file-upload:fileDraggedUpdated', this.fileDragged);
          bus.$emit('site-attachments:load');

          var reader = new FileReader();
          var self = this;
          reader.addEventListener("load", function () {
            self.attachment.file = reader.result.split(',')[1];
          }, false);
          reader.readAsDataURL(fileList[0]);
        }
      },
      mounted() {
        this.reset();
      },
    });

    Vue.component('edit-attachment', {
      template: '#edit-attachment',
      mixins: [fileUtils],
      data: function(){
        return {
          showModal: false,
          attachment: null
        }
      },
      mounted() {
        var self = this;
        bus.$on('edit-attachment:load', function(data){
          self.fetchData(data.id);
        });
      },
      methods: {
        closeModal: function(){
          this.showModal = false;
        },
        fetchData: function(id){
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachments/' + id,
            dataType: 'json',
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                Vue.set(self, 'attachment', response.attachment);
                Vue.set(self, 'showModal', true);
              }
            },
          });
        },
        updateAttachment: function(id){
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachments/' + id,
            method: 'PATCH',
            data: {
              attachment: {
                name: this.attachment.name,
                description: this.attachment.description
              }
            },
            dataType: 'json',
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                bus.$emit('file-popover:load', {id: self.attachment.id});
                Vue.set(self, 'showModal', false);
              }
            },
          });
        },
        attachmentDoc: function(attachment){
          return attachment.file_name + " (" + this.bytesToSize(attachment.file_size) + ")";
        },
      },
    });

    Vue.component('file-popover', {
      template: '#file-popover',
      mixins: [fileUtils],
      props: ['attachableId', 'attachableType'],
      data: function(){
        return {
          show: false,
          attachment: null
        }
      },
      mounted() {
        var self = this;
        bus.$on('file-popover:load', function(data){
          self.fetchData(data.id);
        });
      },
      methods: {
        closePopover: function(){
          this.show = false;
        },
        fetchData: function(id){
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachments/' + id,
            dataType: 'json',
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                Vue.set(self, 'attachment', response.attachment);
                Vue.set(self, 'show', true);
              }
            },
          });
        },
        editAttachment: function(id){
          bus.$emit('edit-attachment:load', {id: id});
        },
        removeAttaching: function(){
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachings',
            method: "DELETE",
            dataType: 'json',
            data: {
              attachment_id: this.attachment.id,
              attachable_id: this.attachableId,
              attachable_type: this.attachableType
            },
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                Vue.set(self, 'show', false);
                bus.$emit('file-list:load');
              } else {
                // TODO: handle errors
              }
            },
          });

        },
      },
    });

    Vue.component('site-attachments', {
      template: '#site-attachments',
      mixins: [fileUtils],
      props: ['attachableId', 'attachableType'],
      data: function(){
        return {
          q: "",
          previousQ: "",
          attachments: [],
          showModal: false,
          fileDragged: false
        }
      },
      methods: {
        searchStringParameters: function(){
          if(this.q === "")
            return {};
          return {search_string: this.q};
        },
        closeModal: function(){
          this.showModal = false;
        },
        formatDate: function(date){
          if (date === undefined || date === null) return "";
          return I18n.l("date.formats.short", date);
        },
        fetchData: function(q){
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachments',
            dataType: 'json',
            data: this.searchStringParameters(),
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                Vue.set(self, 'attachments', response.attachments);
                Vue.set(self, 'showModal', true);
              }
            },
          });
        },
        associateAttachment: function(id){
          console.log(id);
          var self = this;
          $.ajax({
            url: '/admin/attachments/api/attachings',
            dataType: 'json',
            method: "POST",
            data: {
              attachment_id: id,
              attachable_id: this.attachableId,
              attachable_type: this.attachableType
            },
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              bus.$emit('file-list:load');
              Vue.set(self, 'showModal', false);
            },
            error: function(){
              Vue.set(self, 'showModal', false);
            }
          });
        },
        search: function(){
          if(this.q.length > 2){
            this.fetchData(this.q);
          } else if(this.previousQ != this.q) {
              this.fetchData();
          }
          this.previousQ = this.q;
        }
      },
      mounted() {
        var self = this;
        bus.$on('site-attachments:load', function(){
          self.fetchData();
        });
        bus.$on('file-upload:fileDraggedUpdated', function(value){
          self.fileDragged = value;
        });
      },
    });

    Vue.component('file-list', {
      props: ['attachableId', 'attachableType'],
      mixins: [fileUtils],
      template: '#file-list-template',
      data: function(){
        return {
          attachments: [],
          showFiles: false
        }
      },
      methods: {
        popover: function(e) {
          bus.$emit('file-popover:load', {id: $(e.target).data('attachment-id')});
        },
        fetchData: function(){
          var self = this;
          var url = $(self.$options.el).data('data-url');
          $.ajax({
            url: '/admin/attachments/api/attachments',
            data: {
              attachable_type: this.attachableType, attachable_id: this.attachableId
            },
            dataType: 'json',
            beforeSend: function(xhr){ xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')); },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                Vue.set(self, 'attachments', response.attachments);
              } else {
                // TODO: handle errors
              }
            },
          });
        },
      },
      mounted() {
        var self = this;
        self.fetchData();
        bus.$on('file-list:load', function(){
          self.fetchData();
          self.showFiles = true;
        });
      }
    })

    // start app
    var selector = '#gobierto-attachment';
    new Vue({
      el: selector,
      data: {
        attachableType: $(selector).data('attachable-type'),
        attachableId: $(selector).data('attachable-id'),
      },
      methods: {
        loadAttachments: function(){
          bus.$emit('site-attachments:load');
        },
        dragHandler: function(e){
          console.log('Drag handler');
        },
        dropHandler: function(e){
          console.debug(e.dataTransfer.files)
        },
      }
    });
  }

  return GobiertoAttachmentsController;
})();

this.GobiertoAdmin.gobierto_attachments_controller = new GobiertoAdmin.GobiertoAttachmentsController;

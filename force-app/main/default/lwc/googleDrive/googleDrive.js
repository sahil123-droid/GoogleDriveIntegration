import { LightningElement, track, api } from 'lwc';
import checkAuth from '@salesforce/apex/GoogleWebService.checkAuth';
import getDataFromDrive from '@salesforce/apex/GoogleWebService.getDataFromDrive';
import uploadFile from '@salesforce/apex/GoogleWebService.uploadFile';
import renameFile from '@salesforce/apex/GoogleWebService.renameFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class GoogleDrive extends LightningElement {
    data = [];
    @track signin = true;
    msg;

    @track showButton = false;

    fileName;
    mimeType;
    docId;

    queryTerm;
    @track searchedData=[];
    loaded = false;
    @track visibleData=[];

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.js', '.txt'];
    }

    get searchedDataLen(){
        if(this.searchedData.length==0){
            return false;
        }
        return true;
    }
    updatePaginationHandler(evt){
        this.visibleData=[...evt.detail.records];
        console.log(evt.detail.records);
    }
    refreshData(){
        this.handleDataLoad();
    }
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.loaded=false;
            this.queryTerm = evt.target.value;
            console.log(this.queryTerm);
            let temp=[...this.data];
            let searchResults = [];
            for(let i=0;i<temp.length;i++){
                if(temp[i].name.includes(this.queryTerm)){
                    searchResults.push(temp[i]);
                }
            }
            this.searchedData=searchResults;
            console.log('searched',this.searchedData);
            
            this.loaded=true;
        }
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        uploadFile({ docId: uploadedFiles[0].documentId })
            .then(result => {
                console.log(result);
                if (result.includes('200')) {
                    const event = new ShowToastEvent({
                        title: 'File Uploaded Successfully',
                        message: 'File Uploaded Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                }
                else {
                    const event = new ShowToastEvent({
                        title: 'File Upload Error',
                        message: 'Please Upload A File with less than 6 mb size and with acceptable formats(pdf,png,js,jpeg,jpg,txt)',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                }
                this.handleDataLoad();
            })
            .catch(error => {
                console.log(error);
            })

    }

    connectedCallback() {
        checkAuth()
            .then(result => {
                this.signin = result;
                console.log(this.signin);
                if (this.signin == true) {
                    this.handleDataLoad();
                }
            })
            .catch(error => {
                this.msg = error.message;
                this.signin = false;
                console.log(error);
            })
    }
    handleAnchor(evt) {
        alert('Once the Authorization is done ! Make sure to refresh the Page');
    }
    handleDownload(evt) {
        console.log(evt.target.value);
        let link = document.createElement("a");
        link.href = evt.target.value;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    handlePreview(evt) {
        console.log(evt.target.value);
        let link = document.createElement("a");
        link.href = evt.target.value;
        link.target = "_blank";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    handleRename(evt) {
        console.log('rename called');
        this.mimeType = evt.target.value;
        this.docId = evt.target.name;
        let temp = [...this.searchedData];
        const found = temp.findIndex(element => element.id === this.docId);
        temp[found].showInput = true;
        this.searchedData = temp;
        console.log(this.searchedData);
    }
    handleCancel(evt) {
        let temp = [...this.searchedData];
        const found = temp.findIndex(element => element.id === this.docId);
        temp[found].showInput = false;
        this.searchedData = temp;
        this.mimeType = '';
        this.docId = '';
        this.fileName = '';
        console.log('cancel called');
        console.log(this.mimeType);
        console.log(this.docId);
        console.log(this.fileName);
        console.log(this.searchedData);
    }
    handleChange(evt) {
        console.log('change called');
        this.fileName = evt.detail.value;
        console.log(this.fileName);
    }
    handleSave(evt) {
        renameFile({ docId: this.docId, mimeType: this.mimeType, name: this.fileName })
            .then(result => {
                console.log(result);
                if (result.includes('200')) {
                    const event = new ShowToastEvent({
                        title: 'File Renamed Successfully',
                        message: 'File Renamed Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                }
                else{
                    const event = new ShowToastEvent({
                        title: 'File Rename Error',
                        message: 'File Renamed Error',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                }
                let temp = [...this.searchedData];
                const found = temp.findIndex(element => element.id === this.docId);
                temp[found].showInput = false;
                this.searchedData = temp;
                this.mimeType = '';
                this.docId = '';
                this.fileName = '';
                this.showButton=false;
                this.handleDataLoad();
            })
            .catch(result => {
                console.log(error);
            })
    }
    handleFocusOut(evt){
        var regex = /^[a-zA-Z 0-9]+$/i;
        if(regex.test(this.fileName)){
            this.showButton=true;
        }
        else{
            this.showButton=false;
            alert('There is some porblem in name of file It should contains alphanumeric characters and Spaces Only');
        }
    }
    handleDataLoad() {
        this.loaded=false;
        getDataFromDrive()
            .then(result => {
                console.log(result);
                let temp = [];
                for (let item of result.files) {
                    let mimetype = item.mimeType;
                    if (!mimetype.includes('folder')) {
                        let obj = {};
                        obj.name = item.name;
                        obj.id = item.id;
                        obj.displayname = item.name.substring(0, 15) + '...';
                        obj.mimeType = item.mimeType;
                        obj.showInput = false;
                        obj.canRename = item.capabilities.canRename;
                        obj.thumbnailLink = item.thumbnailLink === undefined ? item.iconLink : item.thumbnailLink;
                        if (item.exportLinks) {
                            obj.downloadLink = item.exportLinks["application/pdf"];
                        }
                        obj.iconLink = item.iconLink;
                        obj.webViewLink = item.webViewLink;
                        temp.push(obj);
                    }
                }
                this.queryTerm='';
                this.data = temp;
                this.searchedData=temp;
                console.log('data',this.data);
                console.log('searched data',this.searchedData);
                this.loaded=true;
            })
            .catch(error => {
                console.log(error);
                this.loaded=true;
            })
    }
}
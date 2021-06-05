import { LightningElement, api, wire} from 'lwc';
import { getRecord, updateRecord, getRecordNotifyChange  } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Add additional sObjects here with the Minutes_Spent__c field to support additional objects
const FIELDS = ['Account.Minutes_Spent__c'];

export default class MinutesSpentTracker extends LightningElement {

    @api recordId;

    fields = FIELDS;

    timerRunning = false;
    timeVal = '0:0:0';
    timeIntervalInstance;
    totalMilliseconds = 0;

    @wire(getObjectInfo, { objectApiName: 'Account' }) objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading minutes spent',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.totalMilliseconds = data.fields.Minutes_Spent__c.value > 0 ? data.fields.Minutes_Spent__c.value * 60000 : 0;
            // Time calculations for hours, minutes, seconds and milliseconds
            var hours = Math.floor((this.totalMilliseconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((this.totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((this.totalMilliseconds % (1000 * 60)) / 1000);
            // Output the result in the timeVal variable
            this.timeVal = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0');  
        }
    }

    handleStartStop(){
        if(!this.timerRunning){
            this._startTimer();
            this.timerRunning = !this.timerRunning;
        }
        else{
            this._stopTimer();
            this.timerRunning = !this.timerRunning;
        }
    }

    _startTimer(){
        var parentThis = this;

        // Run timer code in every 100 milliseconds
        this.timeIntervalInstance = setInterval(function() {

            // Time calculations for hours, minutes, seconds and milliseconds
            var hours = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((parentThis.totalMilliseconds % (1000 * 60)) / 1000);
            
            // Output the result in the timeVal variable
            parentThis.timeVal = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0');  
            
            parentThis.totalMilliseconds += 1000;
        }, 1000);
    }

    _stopTimer(){
        clearInterval(this.timeIntervalInstance);
        const fields = {};
        fields.Minutes_Spent__c = Math.round(this.totalMilliseconds / 60000);
        fields.Id = this.recordId;
        const rec = {fields};

        updateRecord(rec)
        .then(() =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Minutes Spent Updated Successfully',
                    variant: 'success'
                })
            )
        })
        .catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating Minutes Spent',
                    message: error.message,
                    variant: 'error'
                })
            )
        })
        
    }

    get btnLabel(){
        return this.timerRunning ? 'Stop' : 'Start';
    }

    get timer(){
        return this.timeVal;
    }

    get header(){
        return this.objectInfo.data?.fields.Minutes_Spent__c?.label ? this.objectInfo.data?.fields.Minutes_Spent__c?.label : 'Minutes Spent';
    }
}
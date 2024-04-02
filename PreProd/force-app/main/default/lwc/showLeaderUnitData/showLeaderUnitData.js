import { LightningElement,api ,track} from 'lwc';
export default class ShowLeaderUnitData extends LightningElement {
 @api unitData;
@track colourName;

 connectedCallback() {
     //this.colourName = unitData.colour;
 }
 get componentStyle() {
        //this.height = (window.innerHeight) * .71;
        return `background-color:${this.unitData.colour}`;
      }
}
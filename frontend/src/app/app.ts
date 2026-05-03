import { Component, OnInit } from '@angular/core';
import { environment } from '../environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  standalone: false,
  styleUrl: './app.css'
})
export class App implements OnInit {
  title = 'frontprojectassignment';


  is_prod=environment.PRODUCTION;
  ngOnInit(): void{
    if (this.is_prod){
      console.log("my environment is PROD")
    }
    else{
      console.log("my environment is DEV")
    }
  }
}

/* pages/_app.js */
import '../styles/globals.css'
import Link from 'next/link'

//lo que nos permite next.js es usar componentes globales persistentes entre cambios de pagina.
function MyApp({ Component, pageProps }) {
  return (
    <div>
 <head><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous"></link>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
</head>
      <nav class="navbar navbar-dark bg-dark fixed-top">
  <div class="container-fluid b">
    <a class="navbar-brand  "  href="#">NFT MARKETPLACE</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasNavbar" aria-controls="offcanvasNavbar">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel">
      <div class="offcanvas-header">
        <h5 class="offcanvas-title" id="offcanvasNavbarLabel">MARKET PLACE MENU</h5>
        <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
      </div>
      <div class="offcanvas-body bg-dark">
        <ul class="navbar-nav justify-content-end flex-grow-1 pe-3">
          <li class="nav-item">
            <a class="nav-link active" aria-current="page" href="/">Home</a>
          </li>
          <li class="nav-item">
            <a class="nav-link"  href="/create-item">Sell Digital Asset</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/my-assets"> My Digital Assets</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/creator-dashboard"> Creator Dashboard</a>
          </li>
          
        </ul>
        
     
      </div>
    </div>
  </div>
</nav>
      <Component {...pageProps} />
    </div>
  )
}

export default MyApp
//notas: 
/**
 * pagePropses un objeto con los accesorios iniciales que 
 * se precargaron para su página mediante uno de nuestros 
 * métodos de obtención de datos ; de lo contrario, es un objeto vacío.
 */
MODULE C;

TYPE B=CARDINAL;

(* mu� bei Export von "B" und "CARDINAL" Fehler melden >>> OK *)

MODULE G;
  IMPORT B;
  EXPORT B, CARDINAL, A;
  
.

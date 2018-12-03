\subsection{Cardano.BM.Configuration.Model}
\label{module:Cardano.BM.Configuration.Model}

%if False
\begin{code}
{-# LANGUAGE OverloadedStrings   #-}

module Cardano.BM.Configuration.Model
    (
      Configuration
    , setup
    , minSeverity
    , setMinSeverity
    , inspectSeverity
    , setSeverity
    , getBackends
    , registerBackend
    , setDefaultBackends
    , getOption
    , findSubTrace
    , setSubTrace
    --, inspectOutput
    --, takedown
    ) where

import           Control.Concurrent.MVar (MVar, newEmptyMVar, putMVar,
                     takeMVar, withMVar)
import qualified Data.Aeson as Aeson
import qualified Data.HashMap.Strict as HM
import           Data.Text (Text, pack)

import           Cardano.BM.Data.Backend
import           Cardano.BM.Data.Severity
import           Cardano.BM.Data.SubTrace

\end{code}
%endif

\subsubsection{Configuration.Model}\label{code:Configuration}
\begin{figure}[htp]
\centering{
  \includegraphics[scale=0.54]{ConfigurationModel.pdf}
}
\caption{Configuration model}\label{fig:configuration}
\end{figure}

\begin{code}
type ConfigurationMVar = MVar ConfigurationInternal
newtype Configuration = Configuration
    { getCG :: ConfigurationMVar }

-- Our internal state; see {-"\nameref{fig:configuration}"-}
data ConfigurationInternal = ConfigurationInternal
    { cgMapSeverity :: HM.HashMap Text Severity
    , cgMapOutput   :: HM.HashMap Text [Backend]
    , cgMapSubtrace :: HM.HashMap Text SubTrace
    , cgOptions     :: HM.HashMap Text Aeson.Object
    , cgMinSeverity :: Severity
    , cgDefBackends :: [Backend]
    }
--    options:  config.logrotation = { maxFiles = 10; maxSize = 5000000 }
--              config.logprefix = { path = "/mnt/disk/spacy" }

\end{code}

\subsubsection{Backend relation}
\begin{code}
getBackends :: Configuration -> Text -> IO (Maybe [Backend])
getBackends configuration name =
    withMVar (getCG configuration) $ \cg -> do
        let outs = HM.lookup name (cgMapOutput cg)
        case outs of
            Nothing -> do
                return $ Just (cgDefBackends cg)
            Just os -> return $ Just os

setDefaultBackends :: Configuration -> [Backend] -> IO ()
setDefaultBackends configuration bes = do
    cg <- takeMVar (getCG configuration)
    putMVar (getCG configuration) $ cg { cgDefBackends = bes }

registerBackend :: Configuration -> Text -> Maybe Backend -> IO ()
registerBackend _ _kn _f = pure () -- TODO
  --  registerBackend "some" (Just Backend { pass' = Katip.pass (show StdoutSK) })
  --  registerBackend "severe.error" (Just Backend { pass' = Katip.pass "StdoutSK::severe.log") })

\end{code}

\subsubsection{Options}
\begin{code}
getOption :: Configuration -> Text -> IO (Maybe Text)
getOption configuration name = do
    withMVar (getCG configuration) $ \cg ->
        case HM.lookup name (cgOptions cg) of
            Nothing -> return Nothing
            Just o -> return $ Just $ pack $ show o

\end{code}

\subsubsection{Global setting of minimum severity}
\begin{code}
minSeverity :: Configuration -> IO Severity
minSeverity configuration = withMVar (getCG configuration) $ \cg ->
    return $ cgMinSeverity cg

setMinSeverity :: Configuration -> Severity -> IO ()
setMinSeverity configuration sev = do
    cg <- takeMVar (getCG configuration)
    putMVar (getCG configuration) $ cg { cgMinSeverity = sev }

\end{code}

\subsubsection{Relation of context name to minimum severity}
\begin{code}
inspectSeverity :: Configuration -> Text -> IO (Maybe Severity)
inspectSeverity configuration name = do
    withMVar (getCG configuration) $ \cg ->
        return $ HM.lookup name (cgMapSeverity cg)

-- if Maybe Severity given is Nothing then the entry for this name is deleted.
setSeverity :: Configuration -> Text -> Maybe Severity -> IO ()
setSeverity configuration name sev = do
    cg <- takeMVar (getCG configuration)
    putMVar (getCG configuration) $ cg { cgMapSeverity = HM.alter (\_ -> sev) name (cgMapSeverity cg) }

\end{code}

\subsubsection{Relation of context name to SubTrace}
A new context may contain a different type of |Trace|.
The function |appendName| (\nameref{code:appendName}) will look up the |SubTrace| for the context's name.
\begin{code}
findSubTrace :: Configuration -> Text -> IO (Maybe SubTrace)
findSubTrace configuration name = do
    withMVar (getCG configuration) $ \cg ->
        return $ HM.lookup name (cgMapSubtrace cg)

setSubTrace :: Configuration -> Text -> Maybe SubTrace -> IO ()
setSubTrace configuration name trafo = do
    cg <- takeMVar (getCG configuration)
    putMVar (getCG configuration) $ cg { cgMapSubtrace = HM.alter (\_ -> trafo) name (cgMapSubtrace cg) }

\end{code}

\subsubsection{Configuration.Model.setup}
\begin{code}
setup :: FilePath -> IO Configuration
setup _fp = do
    cgref <- newEmptyMVar
    putMVar cgref $ ConfigurationInternal HM.empty HM.empty HM.empty HM.empty Debug []
    return $ Configuration cgref

\end{code}
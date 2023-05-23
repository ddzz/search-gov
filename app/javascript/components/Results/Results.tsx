import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { I18n } from "i18n-js";

import { Pagination } from './../Pagination/Pagination';

import './Results.css';

interface ResultsProps {
  query?: string
  results?: {
    title: string,
    url: string,
    thumbnail?: {
      url: string
    },
    description: string,
    updatedDate: string | null,
    publishedDate: string | null,
    thumbnailUrl: string | null
  }[] | null;
  additionalResults?: {
    recommendedBy: string;
    textBestBets: {
      title: string;
      url: string;
      description: string;
    }[];
  } | null;
  unboundedResults: boolean;
  totalPages: number | null;
  vertical: string;
  locale?: {};
}

export const Results = ({ query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, vertical, locale }: ResultsProps) => {
  const i18n = new I18n(locale);
  return (
    <>
      <div className='search-result-wrapper'>
        {additionalResults && additionalResults.textBestBets?.length > 0 && (
          <GridContainer className="results-best-bets-wrapper">
            <Grid row gap="md" id="best-bets">
              <Grid col={true}>
                <GridContainer className='best-bets-title'>
                  Recommended by {additionalResults.recommendedBy}
                </GridContainer>
                {additionalResults.textBestBets.map((textBestBet, index) => {
                  return (
                    <GridContainer key={index} className='result search-result-item boosted-content'>
                      <Grid row gap="md">
                        <Grid col={true} className='result-meta-data'>
                          <div className='result-title'>
                            <a href={textBestBet.url} className='result-title-link'>
                              <h2 className='result-title-label'>{parse(textBestBet.title)}</h2>
                            </a>
                          </div>
                          <div className='result-desc'>
                            <p>{parse(textBestBet.description)}</p>
                            <div className='result-url-text'>{textBestBet.url}</div>
                          </div>
                        </Grid>
                      </Grid>
                    </GridContainer>
                  );
                })}
                <GridContainer className='result search-result-item graphics-best-bets display-none'>
                  <Grid row gap="md">
                    <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                      <img src="https://plus.unsplash.com/premium_photo-1666277012069-bd342b857f89?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=300&q=10" className="result-image"/>
                    </Grid>
                    <Grid col={true} className='result-meta-data'>
                      {/* ToDo: This need to be dynamic */}
                      <div className='graphics-best-bets-title'>
                        Find a Job
                      </div>
                      <Grid row gap="md">
                        <Grid mobileLg={{ col: 7 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>USAJOBS - Federal Government Jobs</a>
                        </Grid>
                        <Grid mobileLg={{ col: 5 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Veterans Employment</a>
                        </Grid>
                        <Grid mobileLg={{ col: 7 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Jobs in Your State</a>
                        </Grid>
                        <Grid mobileLg={{ col: 5 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Disability Resources</a>
                        </Grid>
                        <Grid mobileLg={{ col: 7 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Federal Jobs for Recent Graduates</a>
                        </Grid>
                      </Grid>
                    </Grid>
                  </Grid>
                </GridContainer>
              </Grid>
            </Grid>
          </GridContainer>)}

        <div id="results" className="search-result-item-wrapper">
          {results && results.length > 0 ? (results.map((result, index) => {
            return (
              <GridContainer key={index} className='result search-result-item'>
                <Grid row gap="md">
                  {vertical === 'image' &&
                  <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                    <img src={result.thumbnail?.url} className="result-image" alt={result.title}/>
                  </Grid>
                  }
                  <Grid col={true} className='result-meta-data'>
                    {result.publishedDate && (<span className='published-date'>{result.publishedDate}</span>)}
                    {result.updatedDate && (<span className='published-date'>{' '}&#40;Updated on {result.updatedDate}&#41;</span>)}
                    <div className='result-title'>
                      <a href={result.url} className='result-title-link'>
                        <h2 className='result-title-label'>
                          {result.title} 
                          {/* ToDo: This need to be dynamic */}
                          <span className='filetype-label'>PDF</span>
                        </h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>{result.description}</p>
                      <div className='result-url-text'>{result.url}</div>
                    </div>
                  </Grid>
                </Grid>
              </GridContainer>
            );
          })) : (
            <GridContainer className='result search-result-item'>
              <Grid row>
                <Grid tablet={{ col: true }}>
                  <h4>{i18n.t('no_results_for_and_try', { query: query })}</h4>
                </Grid>
              </Grid>
            </GridContainer>)}
        </div>
      </div>
      <Pagination 
        totalPages={totalPages}
        pathname={window.location.href}
        unboundedResults={unboundedResults}
      />
    </>
  );
};
